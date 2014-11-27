Parsing-References-using-SVM
============================

EXTRACTION OF REFERENCE META DATA

This document gives an overview of the procedure. Refer to individual scripts which are properly commented for any issues.

The target is to extract the meta data from the references. This meta data includes Authors (tagged as <PERSON>), organizations, locations, year of publication, volume, sub-volume, start-page of a reference, end-page and miscellanuous. This has been achieved in two parts. 

EXTRACTION OF NAMES OF AUTHORS, ORGAIZATIONS AND LOCATIONS OF PUBLICATION (ALPHABETS)

For the first part, we have used the Stanford Named Entity Recogniser (available at http://nlp.stanford.edu/software/CRF-NER.shtml). It produces an inlineXML output file which tags the name of the person and the journal name as the organization name in the format as shown below: <PERSON> Lee S.K. </PERSON>. It also produces a MISC tag which identifies many words that don't fall into one of above categories.
 
EXTRACTION OF YEAR, VOLUME, SUB-VOLUME (NUMBERS)

For this part, after analysing various types of documents, we came to the conclusion that hard coding any pattern was not possible. After thinking about various patterns we decided to use the Support Vector Machine (SVM) algorithms to get the required output. SVM classification divides points in an n-dimensional space into categories, the complexity of the boundary largely depending on the type of kernel function used. We have used the libSVM library for implementing SVM algorithms and a gaussian kernel.

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


A. REQUIREMENTS AND ASSUMPTIONS

- Input files should be in .csv format
- final tagged files are contained in the folder named "tagged"
- Estimated time: ~2.72 sec per file

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


B. Step by step implementation:

1. Files are copied from the location specified by the user and zprocess.pl is run to add dots after each single capital letter in the files. This is necessary because the stanford-ner library would tag, say, "Hammond L." as "<PERSON> Hammond L. </PERSON>" but "Hammond L" as "<PERSON> Hammond <PERSON> L". Subsequently, the stanford-ner library functions are used on the csv files to get stage1 (refer above) tagged files.

2. For stage2, first the parser.pl takes original csv files and converts all the numbers therin (ignoring the indexes) to a 3-dimensional vector, with the number being the 2nd and the 1st and 3rd coordinates being the puctuation marks around the number. We've ignored all the alphabets as they've already been tagged in stage1. parser.pl creates files with "trainfile" appended to the basenames, and the format is as required by the libsvm library (Manual_tag/dummy_string\s1st_coordinate,2nd_coordinate,3rd_coordinate).

3. Conversion to svm format:-
super.svm is the master file which contains manually tagged reference metadata (numbers only). 
svm-predict creates super.svm.model which would be used for the final prediction task. 
svm-predict is finally invoked to classify each document and print the tags (in the form of numbers, like "1" for "year", "4" for "volume" etc.) to a file "temp_out...".

4. First column from this file (the numeric tags) are copied and printed to another file "out..." alongwith the vetors to get numbers and their tags in the same row. 

5. Finally, tagger.pl searches for numbers of "out..." in the stage1 tagged files and places tags around them.   

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


C. HOW TO TRAIN REFERENCE TAGGER FOR BETTER RESULTS

1. Copy everthing above (and including) "done" (line 141; till section 3) to a new bash script and comment out the three "rm" commands in lines 137-139.

2. Manually tag all the .csv.svm files in stage2 folder by replacing "0" with the appropriate tag (1-year, 2-start page, 3-end page, 4-volume, 6-subvolume). The number to be tagged is the middle number in each row multiplied by 1000, and the numbers are in the same order as in the original file supplied to the package.

3. Copy all the manually-tagged rows of the .csv.svm files and append them at the end of super.svm.

New training set is ready ! 


