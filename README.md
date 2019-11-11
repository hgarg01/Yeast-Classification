#**Yeast-Classification**
 Multi-label Classification model for yeast in R
 
##Aim
 This project aims to create a multi-label classifier using supervised learning for Ecoli dataset. The dataset is obtained from http://archive.ics.uci.edu/ml/index.php .
 This is a multivariate dataset containing 8 attributes and 1484 instances.

##Imbalanced distribution of classes
 The classes presesnt in the dataset were found to be highly imbalanced. In order to deal with this imbalance, SMOTE(Synthetic Minority Oversampling Technique) has been used. Using SMOTE, samples for minority class are created sythetically and undersampling of the majority class is performed to get a balanced dataset.
 Given data is divided into 2 sets- training set and test set. Model is trained using the training dataset and tested on the test set to get a more accurate picture of how well the model is generalizing.
 
##Training and Evaluating the performance
 Following supervised algorithms are used for training the data:-
### Random Forest
Random forest in an ensemble of many decision trees. As the name suggests, it randomly creates forest with several trees. Generally, the more trees in the forest, the more robust the forest would be. Random forest attempts to increase the generalizing capability of a model by :
 (i) Randomly sampling training data points when building trees and
 (ii) Considering random subsets of features when splitting nodes 
 Best performance for random forest model was found to be at mtry(no of features used) = 3 and ntree(Maximum no of trees in a forest)= 500
 
###Support Vector Machines
 SVM is supervised learning algorithm that aims to classify the various data points by separating them using a hyperplane. In other words, given a set of points, SVM produces a hyper plane that divides these data points into a set of classes.
 The best performance for SVM was found to be the one with the radial kernel and cost = 1000 and gamma = 0.5. Best error rate for testing set was 0.2439 and the best accuracy was 0.7560976.
 
###Ensemble Method
  Ensemble methods is a machine learning technique that combines several base models in order to produce one optimal predictive model.
  For this project, Random forest and SVM methods have been used for base models and they are stacked together by producing a new learner that attemps to improve model performace by generalizing. Two types of new learners for stacking have been in this project- gbm and neural net.
  Neural network was found to perform better than the gbm method. Final accuracy measure of the ensemble was found to be 0.8103. This performance is an improvement over the individual SVM or random forest models. Class error was still an issue for some of the minority classes.

##Scope for improvement
In this project, only 2 base learners have been used. Performance can be improved even further by using other different base learners and combinig them using a new learner on the top. For combining the models, bagging or boosting could be used instead of stacking. Accuracy for the prediction of minority classes could be improved further using weighted random trees.