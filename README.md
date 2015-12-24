# ELEN6886_Fall_2015
The course project by Yi Luo (yl3364) for ELEN6886 in 2015 Fall semester, Columbia University.

===========================================================================
This project is about improving singing separation using dictionary-based low-rank modeling and vocal information.   

We use the Melodia Vamp plugin for singing detection. To successfully run the code, you need to first install Vamp host. You may go through https://code.soundsoftware.ac.uk/projects/vamp-plugin-sdk/wiki/Mtp1 for the installation instructions. Currently our code only support MacOS, and please make sure the path for Vamp is   
```
  HOME/Library/Audio/Plug-Ins/Vamp/vamp-simple-host  
```
After installing Vamp, you need to install the Melodia plugin. It can be found at http://mtg.upf.edu/technologies/melodia. Melodia[1] is an algorithm that estimate the main melody in a polyphonic music, and can be used to estimate the region where singing voice occurs. Please follow the instructions on how to successfully install plugins for Vamp. You can find it on the website above.  


We use MIR1K [2] for evaluation. Please download the MIR1K dataset from https://sites.google.com/site/unvoicedsoundseparation/mir-1k, and put it in the same path with all the codes. To run the evaluation, you need to first use ODL_training.m to train the dictionaries for vocal and non-vocal part, then run evaluate_VIARPCA.m.

----------------------------------------------------------------------------

[1] Salamon J, Gómez E. Melody extraction from polyphonic music signals using pitch contour characteristics[J]. Audio, Speech, and Language Processing, IEEE Transactions on, 2012, 20(6): 1759-1770.
[2] C.-L. Hsu and J.-S. R. Jang. On the improvement of singing voice separation for monaural recordings us- ing the MIR-1K dataset. IEEE Trans. Audio, Speech & Language Processing, 18(2):310–319, 2010.
