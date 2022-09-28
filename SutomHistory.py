# Pre-Requisite Retrieve the full website with wget --mirror https://www.millenium.org

import argparse
import os
import glob
import re
from datetime import date

def init_argparse() -> argparse.ArgumentParser:

    parser = argparse.ArgumentParser(
        usage="%(prog)s [DIRECTORY]",
        description="extract SUTOM answers from an extract of www.millenium.org."
    )


    parser.add_argument('directory', nargs=1)

    return parser

def convertToDate(iStringDate) -> date:
    sDay, sMonth, sYear = iStringDate.split()
    match sMonth:
        case "janvier":
            month=1
        case "fevrier":
            month=2
        case "mars":
           month=3
        case "avril":
           month=4
        case "mai":
           month=5
        case "juin":
           month=6
        case "juillet":
           month=7
        case "août":
           month=8
        case "septembre":
           month=9
        case "octobre":
           month=10
        case "novembre":
           month=11
        case "decembre":
           month=12
        case _:
           print("ERROR - Unrecognised month {}".format(sMonth))
    return date(int(sYear),int(month),int(sDay))

def main() -> None:

    parser = init_argparse()
    args = parser.parse_args()

    directory = args.directory[0]

    #print("Directory provided: {}".format(directory))
    regex_1 = re.compile("<title>[ ]*SUTOM ([0-9]+ \S+ [0-9]+)")
    #regex_1 = re.compile("SUTOM")
    regex_2 = re.compile("<span class=\"js-hint\">([\w]+)</span>")

    # Output dictionary with date -> Sutom result
    dictSutom = {}
    dictURL = {}

    for filename in glob.iglob(directory + '**', recursive=True):
        if os.path.isfile(filename):
            #print(filename)
            with open(filename, 'r') as file:
                buffer = file.read()
                match_1 = regex_1.search(buffer)
                if match_1:
                    #print("{} --> Matched Regex title-SUTOM with value {}".format(filename, match_1.group(1)))
                    match_2 = regex_2.search(buffer)
                    if match_2:
                       #oprint("                    with value {}".format(match_2.group(1)))
                       #print("{},{}".format(match_1.group(1), match_2.group(1)))
                       myDate = convertToDate(match_1.group(1))
                       #print("{},{},{}".format(myDate.strftime("%d-%m-%y"), match_2.group(0),filename))
                       ##dictSutom[myDate.strftime("%d-%m-%y")] = match_2.group(1)
                       dictSutom[myDate] = match_2.group(1)
                       dictURL[myDate] = filename
                file.close()

    for k in sorted(dictSutom.keys()):
        #print("{},{},{}".format(k.strftime("%d-%m-%y"),dictSutom[k],dictURL[k]))
        print("{},{}".format(k.strftime("%d-%m-%y"),dictSutom[k]))


if __name__ == '__main__':
    main()
