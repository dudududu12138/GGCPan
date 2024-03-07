import sys

#get structural variants from all variants
def getSV(var):
  variant=var.split('\t')
  ref=variant[3]
  alle=variant[4]
  lendiff=max(len(ref),len(alle))-min(len(ref),len(alle))
  if lendiff>=50:
    return(1)
  else:
    return(0)


sample=sys.argv[1]
path=path2vcf_files

result=''
f=open(path+sample+'.vcf')
for line in f:
  if line[0]=="#":
    result+=line
  else:
    ifsv=getSV(line)
    gq=int(line.split('\t')[5])
    if ifsv==1 and gq>=60:
      result+=line

f.close()
f=open(path+sample+'.sv.vcf','w')
f.write(result)
f.close()
