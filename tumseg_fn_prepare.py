
import os, sys, socketio

from auxiliary.normalization.percentile_normalizer import PercentileNormalizer
from auxiliary.turbopath import turbopath
from tqdm import tqdm

import importlib

from brainles_preprocessing.brain_extraction import HDBetExtractor
from brainles_preprocessing.modality import Modality
from brainles_preprocessing.preprocessor import Preprocessor
from brainles_preprocessing.registration import (
    ANTsRegistrator,
    NiftyRegRegistrator,
    eRegRegistrator,
)


# This script is an example of how to use the ModalityCentricPreprocessor class to 
# preprocess a set of MR images. It is only here for quick development and testing purposes. 
# It is not intended to be used in a production environment.


def preprocess(brainles_dir, t1File, t1cFile, t2File, flaFile):

    print("*** start ***")
    print(t1File)
    print(t1cFile)
    print(t2File)
    print(flaFile)

    raw_bet_dir = brainles_dir / "raw_bet"
    norm_bet_dir = brainles_dir / "normalized_bet"
    raw_skull_dir = brainles_dir / "raw_skull"
    norm_skull_dir = brainles_dir / "normalized_skull"
    
    if 1:
        
        # normalizer
        percentile_normalizer = PercentileNormalizer(
            lower_percentile=0.1,
            upper_percentile=99.9,
            lower_limit=0,
            upper_limit=1,
        )
        
        # define modalities
        center = Modality(
            modality_name="t1c",
            input_path=t1cFile,
            raw_bet_output_path=raw_bet_dir / "t1c_bet_raw.nii.gz",
            raw_skull_output_path=raw_skull_dir / "t1c_skull_raw.nii.gz",
            normalized_bet_output_path=norm_bet_dir / "t1c_bet_normalized.nii.gz",
            normalized_skull_output_path=norm_skull_dir / "t1c_skull_normalized.nii.gz",
            atlas_correction=True,
            normalizer=percentile_normalizer,
        )
        
        moving_modalities = [
            Modality(
                modality_name="t1",
                input_path=t1File,
                raw_bet_output_path=raw_bet_dir / "t1_bet_raw.nii.gz",
                raw_skull_output_path=raw_skull_dir / "t1_skull_raw.nii.gz",
                normalized_bet_output_path=norm_bet_dir / "t1_bet_normalized.nii.gz",
                normalized_skull_output_path=norm_skull_dir / "t1_skull_normalized.nii.gz",
                atlas_correction=True,
                normalizer=percentile_normalizer,
            ),
            Modality(
                modality_name="t2",
                input_path=t2File,
                raw_bet_output_path=raw_bet_dir / "t2_bet_raw.nii.gz",
                raw_skull_output_path=raw_skull_dir / "t2_skull_raw.nii.gz",
                normalized_bet_output_path=norm_bet_dir / "t2_bet_normalized.nii.gz",
                normalized_skull_output_path=norm_skull_dir / "t2_skull_normalized.nii.gz",
                atlas_correction=True,
                normalizer=percentile_normalizer,
            ),
            Modality(
                modality_name="flair",
                input_path=flaFile,
                raw_bet_output_path=raw_bet_dir / "fla_bet_raw.nii.gz",
                raw_skull_output_path=raw_skull_dir / "fla_skull_raw.nii.gz",
                normalized_bet_output_path=norm_bet_dir / "fla_bet_normalized.nii.gz",
                normalized_skull_output_path=norm_skull_dir / "fla_skull_normalized.nii.gz",
                atlas_correction=True,
                normalizer=percentile_normalizer,
            ),
        ]

        preprocessor = Preprocessor(
            center_modality=center,
            moving_modalities=moving_modalities,
            # choose the registration backend you want to use
            # registrator=NiftyRegRegistrator(),
            registrator=ANTsRegistrator(),
            # registrator=eRegRegistrator(),
            brain_extractor=HDBetExtractor(),
            temp_folder="temporary_directory",
            limit_cuda_visible_devices="0",
        )

        preprocessor.run(
            save_dir_coregistration=brainles_dir + "/co-registration",
            save_dir_atlas_registration=brainles_dir + "/atlas-registration",
            save_dir_atlas_correction=brainles_dir + "/atlas-correction",
            save_dir_brain_extraction=brainles_dir + "/brain-extraction",
        )


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
    
    
    preprocess(turbopath(output_dir), t1, t1c, t2, flair)



if (__name__ == "__main__"):
	main()
