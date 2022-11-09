#!/usr/bin/env python3

import argparse
import logging
import traceback
from vqm.model import VQM


def main():
    # CLI interface
    parser = argparse.ArgumentParser(
        description="Video quality metric example",
        epilog="your_name, 2022",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "pvs_video", 
        type=str, 
        help="input video location to estimate quality"
    )
    parser.add_argument(
        "ref_video",
        type=str,
        help="reference video location",
    )
    parser.add_argument(
        "result_file",
        type=str,
        help="location to store video quality results",
    )

    args = parser.parse_args()

    try:
        print(f"Input Arguments: {args.pvs_video}, {args.ref_video}, {args.result_file}")
        result = VQM(args.pvs_video, args.ref_video).predict()
        with open(args.result_file, 'w') as fp:
            fp.write(str(result))
        
    except Exception as e:
        logging.error(f"there was a problem while processing {args.pvs_video}. Error: {str(e)}")
        traceback.print_exc()
        logging.error(str(e))
        return 1
    return 0

