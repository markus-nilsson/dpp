import sys

from brats import AdultGliomaPreTreatmentSegmenter
from brats.constants import AdultGliomaPreTreatmentAlgorithms

def main():
    args = sys.argv[1:]
    
    if (len(args) < 5):
    	print('need five arguments')
    	return
    
    segm = args[0]
    t1 = args[1]
    t1c = args[2]
    t2 = args[3]
    flair = args[4]
    
    print("segm: " + segm)
    print("t1:  " + t1)
    print("t1c: " + t1c)
    print("t1:  " + t2)
    print("fla: " + flair)

    segmenter = AdultGliomaPreTreatmentSegmenter(algorithm=AdultGliomaPreTreatmentAlgorithms.BraTS23_1, cuda_devices="0")

    # these parameters are optional, by default the winning algorithm of 2023 will be used on cuda:0
    segmenter.infer_single(t1c=t1c, t1n=t1c, t2f=flair, t2w=t2, output_file=segm)


if (__name__ == "__main__"):
	main()
