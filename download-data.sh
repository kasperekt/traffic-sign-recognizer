#!/bin/sh

wget http://benchmark.ini.rub.de/Dataset/GTSRB_Final_Training_Images.zip
wget http://benchmark.ini.rub.de/Dataset/GTSRB_Final_Test_Images.zip
wget http://benchmark.ini.rub.de/Dataset/GTSRB_Final_Test_GT.zip

unzip GTSRB_Final_Training_Images.zip
unzip GTSRB_Final_Test_Images.zip
unzip GTSRB_Final_Test_GT.zip

mv GT-final_test.csv GTSRB/
rm GTSRB_Final_Training_Images.zip GTSRB_Final_Test_Images.zip GTSRB_Final_Test_GT.zip