#!/bin/bash

#### 1.  SPECIFY DIRECTORIES   ####

echo "Supply the path to Taggerfinal below (without the /):"
read src
echo "Supply the path to directory containing original files (without the /):"
read files

#src='/home/prabhat/Desktop/Taggerfinal'
srcstage1=$src"/stage1"
#files='/home/prabhat/a/*'
files=$files"/*"
####   COPY INPUT FILES AND PUT . AFTER EACH SINGLE CAPITAL CHARACTER   ####
##############################################################################
# This is the final bash script that user has to run and it asks for source  #
# file or directory which contains the files to be processed. It then calls  #
# for the preprocessing script to modify the files and add the dots.         #
##############################################################################
cp $files $srcstage1
echo "-------------------------------------------------------------------"
echo "-------------------------------------------------------------------"
echo "stage1 files successfully copied to stage1 Folder" 
echo "-------------------------------------------------------------------"
echo "-------------------------------------------------------------------"
cd stage1
perl zprocess.pl $srcstage1"/*"
cd ..

#### 2.  INITIAL CLASSIFICATION INTO Author, Location, Organization etc.  ####

##############################################################################
# INFO ABOUT PARAMETERS AND TRAINING					     #
# -loadClassifier: The Stanford NER provides different classifiers (depending#
# on number of classes in which references have to be classified.            #
# After some experimention, we concluded that the 4-class classifier would   #
# best suit our needs. 							     #
# -outputFormat: The Stanford NER provides both XML and inlineXML output     #
# formats. There are some problems with their XML ouptut as some of them are #
# not properly formatted and it's also difficult to integrate them with the  #
# second part. So, we are using inlineXML output format which makes for an   #
# easy reading and easy processing as well.				     #
#									     #
#                           TRAINING					     #
#									     #
# (http://nlp.stanford.edu/software/crf-faq.shtml#b) is the stanford tutorial#
# on the training and can be easily replicated. But it has its limitations   #
# and we haven't had a very good experience with it.			     #
##############################################################################
echo "Stage 1 tagging in proces.........................................."
echo "-------------------------------------------------------------------"
echo "-------------------------------------------------------------------"
for f in $srcstage1/*; do
if [[ ${f: -4} == ".csv" ]]
   then
   java -mx500m -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier classifiers/english.conll.4class.distsim.crf.ser.gz -textFile $f -outputFormat inlineXML > $f.xml
# delete files modified by zprocess.pl 
rm $f
fi
done

## 3. CREATE trainfile...csv -> trainfile...csv.svm -> temp_outtrainfile... -> outtrain...  ####
##############################################################################
# Here, the result of the learning phase, super.svm.model is generated by    #
# using super.svm. It is trained using train-svm executable avialable in     #
# the libSVM package (http://www.csie.ntu.edu.tw/~cjlin/libsvm/). This file  #
# currently has about 4700 data points and we need to add more training point#
# -s to get a good output. In our trials, the outcome has accuracy of about  #
# 95%.                                                                       # 	
##############################################################################
##############################################################################
#                             TRAINING                                       #
#                                                                            #
# libSVM requires its training files to be in the .svm format. These are tab #
# separated values where the first column indicate the classification categor#
# -y and the other indices indicate the co-ordinates. A new point starts with#
# a new line. In our case, it looks like this                                #
# 1             1:1.300000    2:2.004    3:0.500                             #
# (category)      (co-ordinates)                                             #
# parser.pl produces a .csv file. Executing the convert.c file on this gives #
# us the required .svm file format. For the preparation of training file one #
# has to manually label the points. One can use the svm-train file to train  #
# the system. It creates a .model file which is then used to classify the    #
# points. From the official documentation of libSVM, it can be used as 	     #
# Usage: svm-train [options] training_set_file [model_file]		     #
# options:								     #
# -s svm_type : set type of SVM (default 0)     		             #
#	0 -- C-SVC		(multi-class classification)                 #
#	1 -- nu-SVC		(multi-class classification)                 #
#	2 -- one-class SVM	                                             #
#	3 -- epsilon-SVR	(regression)                                 #
#	4 -- nu-SVR		(regression)                                 #
# -t kernel_type : set type of kernel function (default 2)                   # 
#	0 -- linear: u'*v                                                    #
#	1 -- polynomial: (gamma*u'*v + coef0)^degree                         #
#	2 -- radial basis function: exp(-gamma*|u-v|^2)		             #
#	3 -- sigmoid: tanh(gamma*u'*v+coef0)				     #
#	4 -- precomputed kernel (kernel values in training_set_file)         #
# -d degree : set degree in kernel function (default 3)                      #
# -g gamma : set gamma in kernel function (default 1/num_features)           #
# -r coef0 : set coef0 in kernel function (default 0)                        #
# -c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)#
# -n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR          #
#         (default 0.5)		        				     #
# -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1) #
# -m cachesize : set cache memory size in MB (default 100)		     #
# -e epsilon : set tolerance of termination criterion (default 0.001)        # 
# -h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1) #
# -b probability_estimates : whether to train a SVC or SVR model for         #
#                            probability estimates, 0 or 1 (default 0)	     #
# -wi weight : set the parameter C of class i to weight*C, for C-SVC         #
#              (default 1)                                                   #
#-v n: n-fold cross validation model                                         #
#-q : quiet mode (no outputs)                                                #
# The k in the -g option means the number of attributes in the input data.   #
# We used the default parameters and the radial basis in our training set    #
# and the classification category used are mentioned below.		     #
# 	Category                   Class                                     #
#        1 		           Year          	                     #
#        2			   Start Page                                #
#        3                         End Page                                  #
#        4                         Volume                                    #
#        6                         Sub-volume                                #
##############################################################################
cp $files $src"/stage2"
echo "-------------------------------------------------------------------"
echo "-------------------------------------------------------------------"
echo "Files successfully copied to stage2"
echo "-------------------------------------------------------------------"
echo "-------------------------------------------------------------------"
echo "Creating trainfiles................................................"
cd stage2
perl parser.pl $src"/stage2/*" 		       # create trainfiles
srctemp=$src"/stage2/*.csv"
echo "Creating super.svm.model..........................................."
svm-train super.svm;                           # create super.svm.model  
echo "Generating tags...................................................."
for f in $srctemp; do 
if [[ $f == *train* ]]
   then
    ./a.out $f > $f.svm;
  fi
done
srctemp2=$src"/stage2/*.csv.svm"
for g in $srctemp2; do
base=` echo $(basename $g)|cut -d'.' --complement -f2-` #extract basename of files -> train1010101
 svm-predict $g super.svm.model temp_out$base 
 awk 'NR==FNR {x[NR] = $1} NR != FNR {print x[FNR], $0}' temp_out$base $base.csv > out$base 
              #copy 1st line from outtrain101010.csv to out$base.csv and other lines from $base.csv
rm temp_out$base                                        #remove temp_out files
rm $base.csv.svm                                        #remove svm files
rm $base.csv                                            #remove trainfile101010.csv
  ((i++)) 
done

#### 4.   COPY outtrain.... to .../stage1/ AND USE TAGGER    ####

rsync -avm --remove-source-files --include='*outtrain*' -f 'hide,! */' . $srcstage1
cp $srcstage1"/stage2/*" $srcstage1
rm -r $srcstage1"/stage2"
cd ..
cd stage1
perl tagger.pl $srcstage1"/*"
cd ..
mkdir tagged
rsync -avm --remove-source-files --include='*tagged*' -f 'hide,! */' . $srcstage1
srcstage1stage1=$srcstage1"/stage1/*"
srctagged=$src"/tagged"
cp $srcstage1stage1 $srctagged
rm -r $srcstage1"/stage1"
rm -r $srcstage1"/tagged"
bash refresh.sh 
