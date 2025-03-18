
import os, sys, socketio
from auxiliary.turbopath import turbopath

import datetime

from brats_toolkit.segmentor import Segmentor

def segment(outputFolder, t1File, t1cFile, t2File, flaFile):

    # log
    starttime = str(datetime.datetime.now().time())
    print("*** starting at", starttime, "***")

    # instantiate
    seg = Segmentor(verbose=True)

    # algorithms we want to select for segmentation

    # 2019 algorithms
    # cids = ["mic-dkfz", "scan", "xfeng", "lfb_rwth", "zyx_2019", "scan_2019"]

    # 2020 algorithms
    cids = ["isen-20", "hnfnetv1-20", "yixinmpl-20", "sanet0-20", "scan-20"]

    # execute it
    for cid in cids:
        try:
            outputFile = outputFolder + cid + ".nii.gz"
            seg.segment(
                t1=t1File,
                t2=t2File,
                t1c=t1cFile,
                fla=flaFile,
                cid=cid,
                outputPath=outputFile,
            )

        except Exception as e:
            print("error:", str(e))
            print("error occured for:", cid)

    # log
    endtime = str(datetime.datetime.now().time())
    print("*** finished at:", endtime, "***")



def main():
    args = sys.argv[1:]
    
    if (len(args) < 5):
    	print('need five arguments')
    	return
    
    output_dir = args[0]
    t1 = args[1]
    t1c = args[2]
    t2 = args[3]
    flair = args[4]
    
    print("output_dir: " + output_dir)
    print("t1:  " + t1)
    print("t1c: " + t1c)
    print("t1:  " + t2)
    print("fla: " + flair)
    
    
    segment(turbopath(output_dir), t1, t1c, t2, flair)



if (__name__ == "__main__"):
	main()
