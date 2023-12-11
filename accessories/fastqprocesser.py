#Code title: Fastq Processor
#Purpose: Trim the sequences of fastq files to desired length. Option to trim from start or end of sequence also provided. Native code, doesn't need any additional library. Average read quality based filtration is also possible.
#Author: Sunil Nagpal
#version: 1.0

import sys
import argparse


def trim_sequence(sequence, quality,target_length, min_seq,trim_end=True):
	if len(sequence) <= target_length:
		return sequence[:len(sequence)], quality[:len(sequence)]
	else:
		if trim_end:
			return sequence[:target_length],quality[:target_length]
		else:
			return sequence[-target_length:],quality[-target_length:]



def calculate_average_quality(quality_scores):
	total = 0
	for score in quality_scores:
		total += ord(score) - 33  # Convert ASCII to Phred score
	return total / len(quality_scores)


def trim_fastq_sequences(input_file, output_file, target_length, min_seq, max_seq, min_qual,trim_end=True):
	with open(output_file, 'w') as out_f:
		with open(output_file+"_failed.fq",'w') as fout_f:
			with open(input_file, 'r') as in_f:
				while True:
					header = in_f.readline().strip()
					if not header:
						break

					sequence = in_f.readline().strip()
					plus_line = in_f.readline().strip()
					quality = in_f.readline().strip()

					trimmed_sequence, trim_qual = trim_sequence(sequence, quality, target_length,min_seq, trim_end)
					if len(sequence) >= 50:
						quality_of_trimmed=calculate_average_quality(trim_qual)
					else:
						quality_of_trimmed=0
					if ((len(trimmed_sequence) <= target_length) and (len(sequence) >= min_seq) and (len(sequence) <= max_seq) and (quality_of_trimmed >= min_qual)):
						out_f.write(header + ' EndTrimmed:'+ str(trim_end) + ' trimmedlength:'+str(len(trimmed_sequence))+' original:' +str(len(sequence))+' AvgPhredTrimmed:' +str(quality_of_trimmed) +'\n')
						out_f.write(trimmed_sequence + '\n')
						out_f.write(plus_line + '\n')
						out_f.write(trim_qual + '\n')
						print(str(len(trimmed_sequence))+"\t"+str(quality_of_trimmed))
					else:
						if len(sequence)<min_seq or len(sequence)>max_seq:
							fout_f.write(str(len(sequence))+"\t"+str(quality_of_trimmed)+"\n")

def main():
	parser = argparse.ArgumentParser(description='Trim FASTQ sequences to a specified length.')
	parser.add_argument('input_file', help='Input FASTQ file')
	parser.add_argument('output_file', help='Output FASTQ file')
	parser.add_argument('min_seq', type=int, help='Filter out the read if length of sequence is less than min_seq')
	parser.add_argument('max_seq', type=int, help='Filter out the read if length of sequence is more than max_seq')
	parser.add_argument('target_length', type=int, help='Desired target length for sequences')
	parser.add_argument('min_qual', type=int, help='Filter out the read if average quality of trimmed sequence is less than min_qual')

	parser.add_argument('--trim_end', action='store_true', help="Specify --trim_end to disable trimming sequences from the end (default is trim from end) i.e. trim from 5' and not from the 3' tail")
	args = parser.parse_args()



	if args.trim_end:
        	args.trim_end = False
	else:
		args.trim_end = True


	trim_fastq_sequences(args.input_file, args.output_file, args.target_length,args.min_seq,args.max_seq,args.min_qual, args.trim_end)

if __name__ == '__main__':
    main()
