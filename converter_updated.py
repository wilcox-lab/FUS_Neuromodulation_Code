
import os
import glob
cwd = os.getcwd()
files = glob.glob(cwd + '/*.acq')

for file in files: 
    mat = file.replace('.acq','.mat')
    cmd = "acq2mat " + file + " " + mat 
    print(f'Succesfully converted file {file} to file {mat}\n')
    os.system(cmd)