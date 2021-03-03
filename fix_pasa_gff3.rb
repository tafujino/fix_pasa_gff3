#!/usr/bin/env ruby

# frozen_string_literal: true

require 'csv'

require_relative 'gff3_entry'

# @param gff3_entries [Array<Gff3Entry>] should be non-empty
def write_gene(gff3_entries)
  gene_mandatory_fields = gff3_entries.first.mandatory_fields.clone
  gene_mandatory_fields[Gff3Entry::TYPE_COL_INDEX] = 'gene'
  gene_mandatory_fields[Gff3Entry::START_COL_INDEX] = gff3_entries.first.start_pos
  gene_mandatory_fields[Gff3Entry::END_COL_INDEX] = gff3_entries.last.end_pos
  gene = gff3_entries.first.attributes[:ID]
  puts Gff3Entry.new(gene_mandatory_fields, { ID: gene })
  gff3_entries.each do |gff3|
    exon_mandatory_fields = gff3.mandatory_fields.clone
    exon_mandatory_fields[Gff3Entry::TYPE_COL_INDEX] = 'exon'
    exon_attributes = gff3.attributes
    exon_attributes.delete(:ID)
    exon_attributes[:Parent] = gene
    puts Gff3Entry.new(exon_mandatory_fields, exon_attributes)
  end
  puts '###'
end

buffer = []
puts '##gff-version 3'
STDIN.each(chomp: true) do |line|
  next if line =~ /^#/

  gff3 = Gff3Entry.parse(line)
  if buffer.empty? ||
     buffer.last.attributes[:ID] == gff3.attributes[:ID]
    buffer << gff3
  else
    write_gene(buffer)
    buffer = [gff3]
  end
end

write_gene(buffer) unless buffer.empty?
