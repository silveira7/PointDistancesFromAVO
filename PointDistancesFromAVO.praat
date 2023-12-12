# PointDistancesFromAVO.praat
#
# Script implemented by Gustavo de C. P. da Silveira (IEL/University of Campinas, Brazil).
# It measures the distance of maxima and minima velocity and acceleration 
# points (only the nearest points are measured) from the acoustic vowel onset (AVO) e 
# genereates a CSV table with these measures.
#
# This script is supposed to be used in conjunction with Barbosa's 
# ConvertArticDatatoPraat.praat
#
# The TextGrids must be in the same folder of the script.
#
# Obligatory tiers: 
#   - maxDisp: Tier of points indicating maxima displacement
#   - maxVel: Tier of points indicating maxima velocity
#   - minVel: Tier of points indicating minima velocity
#   - maxAcc: Tier of points indicating maxima acceleration velocity
#   - minAcc: Tier of points indicating minima velocity
#   - vowelOnset: Tier of intervals delimiting the onset of vowels
#
# Copyright (C) 2023  Silveira, G. C. P.
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; version 2 of the License.
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
# 
# Date: Version (1.0): December 12th, 2023

form: "Compute the distances of points from vowel onsets"
    comment: "Specify the position of each tier (all are required)."
    integer: "Maxima_Displacement", "1"
    integer: "Maxima_Velocity", "2"
    integer: "Minima_Velocity", "3"
    integer: "Maxima_Acceleration", "4"
    integer: "Minima_Acceleration", "5"
    integer: "Vowel_Onset", "6"
endform

fileList = Create Strings as file list: "fileList", "*.TextGrid"
numberOfFiles = Get number of strings
if !numberOfFiles
	exit There are no txt files (tables) in the folder!
endif

writeFileLine: "ComputeDistancesData.csv", "audiofile, maxDisp, maxVel, minVel, maxAcc, minAcc, nearestOne"

for file from 1 to numberOfFiles
    selectObject: fileList
    filename$ = Get string: file
    Read from file: filename$
    numOfIntervals = Get number of intervals: vowel_Onset
    for i from 2 to numOfIntervals
        vowelOnsetTime = Get start time of interval: vowel_Onset, i

        diffs# = zero# (5)

        procedure computeDistance: .tier
            nearestPoint = Get nearest index from time: .tier, vowelOnsetTime
            pointTime =  Get time of point: .tier, nearestPoint
            diffs# [.tier] = abs(vowelOnsetTime - pointTime)
        endproc

        @computeDistance: maxima_Displacement
        @computeDistance: maxima_Velocity
        @computeDistance: minima_Velocity
        @computeDistance: maxima_Acceleration
        @computeDistance: minima_Acceleration

        nearestOne =  min(diffs#)

        j = 1
        while nearestOne != diffs# [j]
            j = j + 1
        endwhile

        if j == 1
            nearestOne$ = "maxDisp"
        elsif j == 2
            nearestOne$ = "maxVel"
        elsif j == 3
            nearestOne$ = "minVel"
        elsif j == 4
            nearestOne$ = "maxAcc"
        elsif j == 5
            nearestOne$ = "minAcc"
        endif

        appendFileLine: "ComputeDistancesData.csv", filename$ - ".TextGrid", ", ", fixed$ (diffs# [1], 3), ", ", fixed$ (diffs# [2], 3), ", ", fixed$ (diffs# [3], 3), ", ", fixed$ (diffs# [4], 3), ", ", fixed$ (diffs# [5], 3), ", ", nearestOne$
    endfor
endfor

writeInfoLine: "Finished."
