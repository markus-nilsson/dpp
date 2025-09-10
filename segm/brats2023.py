#!/usr/bin/env python3
import sys
import argparse
from typing import Any, Dict, Type

# Segmenters
from brats import (
    AdultGliomaPreTreatmentSegmenter,
    AdultGliomaPostTreatmentSegmenter,
    AfricaSegmenter,
    GoATSegmenter,
    MeningiomaSegmenter,
    MetastasesSegmenter,
    PediatricSegmenter,
)

# Map CLI name -> SegmenterClass
SEGMENTERS: Dict[str, Type] = {
    "adult_pre":   AdultGliomaPreTreatmentSegmenter,
    "adult_post":  AdultGliomaPostTreatmentSegmenter,
    "africa":      AfricaSegmenter,
    "goat":        GoATSegmenter,
    "meningioma":  MeningiomaSegmenter,
    "metastases":  MetastasesSegmenter,
    "pediatric":   PediatricSegmenter,
}

def parse_args(argv):
    p = argparse.ArgumentParser(
        description="BraTS segmentation CLI with segmenter-only selection."
    )
    p.add_argument("output_seg", help="Output segmentation file path")
    p.add_argument("--segmenter", required=True, choices=SEGMENTERS.keys(),
                   help="Segmentation model / dataset context")
    p.add_argument("--cuda-devices", default="0", help='CUDA device list (e.g. "0" or "0,1").')
    p.add_argument("--cpu", action="store_true", help="Force CPU if supported.")
    # Modalities (optional; provide the ones required by your segmenter)
    p.add_argument("--t1",    dest="t1n", help="T1 non-contrast")
    p.add_argument("--t1c",   dest="t1c", help="T1 post-contrast")
    p.add_argument("--t2",    dest="t2w", help="T2-weighted")
    p.add_argument("--flair", dest="t2f", help="FLAIR (T2-FLAIR)")
    return p.parse_args(argv)

def main(argv=None):
    args = parse_args(argv or sys.argv[1:])

    seg_cls = SEGMENTERS[args.segmenter]

    # Debug: high-level config
    print("=== BraTS2023 CLI Debug Info ===")
    print(f"Segmenter: {args.segmenter} -> {seg_cls.__name__}")
    print(f"CUDA devices: {args.cuda_devices} | Force CPU: {bool(args.cpu)}")
    print(f"Output file: {args.output_seg}")

    # Construct segmenter (uses its internal default algorithm)
    segmenter = seg_cls(
        cuda_devices=args.cuda_devices,
        force_cpu=bool(args.cpu),
    )

    # Gather modalities
    infer_kwargs = {"output_file": args.output_seg}
    for k in ("t1c", "t1n", "t2f", "t2w"):
        v = getattr(args, k, None)
        if v:
            infer_kwargs[k] = v

    # Debug: show modalities
    if len(infer_kwargs) > 1:
        print("Modalities provided:")
        for k, v in infer_kwargs.items():
            if k != "output_file":
                print(f"  {k}: {v}")
    else:
        print("No modalities provided.")

    # Minimal sanity: at least one modality should be present
    if len(infer_kwargs) == 1:
        print("ERROR: Provide required modalities for the chosen segmenter (e.g., --t1c, --t1, --t2, --flair).")
        return 2

    print("Starting inference...")
    segmenter.infer_single(**infer_kwargs)
    print("Inference complete.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
