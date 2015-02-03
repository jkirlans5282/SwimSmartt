import glob
output=[]
for filename in glob.glob('*.txt'):
	FILE=open(filename, 'r+')
	x=FILE.readline()
	x=x.strip()
	x+="\ndata = [[NSMutableArray alloc] initWithObjects:"
	output.append(x)
	for line in FILE:
		if line=="\n":
			line="----------"
		line=line.strip('\n')
		line='@"'+line+'",'
		output.append(line)
	output[-1]='nil];\n'
	output.append('\n')

fileout=open('out.txt', 'w')
for item in output:
	fileout.write(item)