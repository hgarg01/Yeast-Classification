#Load the data
yeast <- read.table(file = "clipboard", sep = "\t", header = FALSE,dec = '.')
colnames(yeast) = c( 'mcg','gvh','alm','mit','erl','pox','vac','nuc','class')

#Check the summary of the dataset 
head(yeast)
str(yeast)
summary(yeast)

#Check if the has any blank entries 
is.na(yeast)
#Total entries with blank entries
sum(is.na(yeast))
boxplot(yeast)

library(DMwR)

#number of rows that are not complete
nrow(yeast[!complete.cases(yeast),])



#Normalization of columns using the formula 
yeast$mcg <- (yeast$mcg-mean(yeast$mcg))/sd(yeast$mcg)
yeast$gvh <- (yeast$gvh-mean(yeast$gvh))/sd(yeast$gvh)
yeast$alm <- (yeast$alm-mean(yeast$alm))/sd(yeast$alm)
yeast$mit <- (yeast$mit-mean(yeast$mit))/sd(yeast$mit)
yeast$erl <- (yeast$erl-mean(yeast$erl))/sd(yeast$erl)
yeast$pox <- (yeast$pox-mean(yeast$pox))/sd(yeast$pox)
yeast$vac <- (yeast$vac-mean(yeast$vac))/sd(yeast$vac)
yeast$nuc <- (yeast$nuc-mean(yeast$nuc))/sd(yeast$nuc)
boxplot(yeast)


#Check the distribution of classes in thedataset
library(UBL)
table(yeast$class)
smoted_yeast = SmoteClassif(class ~., yeast, C.perc ="balance", k= 4)
table(smoted_yeast$class)

summary(yeast)
library(ggplot2)


#Check correlation amongst the variables
library(corrplot)
corrplot.mixed(cor(smoted_yeast[,-9]),upper = "circle")


#Create training and test datasets for validation
library(caret)
set.seed(10)
index <- createDataPartition(smoted_yeast$class, p = 0.75, list = FALSE) 
trainSet <- smoted_yeast[index,]
testSet <- smoted_yeast[-index,]

#Random forest model

library(randomForest)
model.rf <- randomForest(class ~ ., data = trainSet, ntry = 2,method = 'rf', trControl = trainControl(method = 'cv', number = 5),ntree = 500,nodesize = 10,importance = TRUE)
print(model.rf)
plot(model.rf)

rf.pred <- predict(model.rf, newdata = testSet)
rf.pred.prob <- predict(model.rf, newdata = testSet, type = "prob")
testSet$pred_cls <- predict(model.rf, newdata = testSet)
confusionMatrix(rf.pred, testSet$class)$overall[1]
confusionMatrix(testSet$class, testSet$pred_cls)
importance(model.rf)
varImpPlot(model.rf)
barplot(sort(importance(model.rf)[,1], decreasing = TRUE),
        xlab = "Relative Importance",
        horiz = TRUE,
        col = "red",
        las=1)
#Plot a graph of test error rate vs mtry
testErrorRate <- rep(0,7)
for(i in 1:7){
  set.seed(6)
  rf.tune <- randomForest(class ~ .-class,
                                data=trainSet,
                                mtry=i,
                                importance=TRUE,
                                ntree=500)
  testErrorRate[i] <- rf.tune$err.rate[500,1]
}
plot(testErrorRate,type="b",xlab="mtry",ylab="Test Error Rate")

#SVM model
library(e1071)

#tune linear model
svm.tune.linear <- tune(svm, class ~., data = trainSet, kernel = "linear", ranges = list(cost = c(0.01,0.1,1,10,100,1000)), probability = TRUE)
summary(svm.tune.linear)
svm.linear.pred <- predict(svm.tune.linear$best.model, newdata = testSet)
mean(svm.linear.pred == testSet$class)

#tune radial model
svm.tune.radial <- tune(svm, class~., data = trainSet, kernel = "radial", ranges = list(cost = c(0.01,0.1,1,10,100,1000), (gamm = c(0.5,1,2,3,4))))
summary(svm.tune.radial)
svm.radial.pred <- predict(svm.tune.radial$best.model, newdata = testSet)
mean(svm.radial.pred != testSet$class)

#best SVM 
best.svm <- svm(class ~., data = trainSet, kernel = "radial", cost = 1000, gamma = 0.5, probability = TRUE)
summary(best.svm)
svm.pred <- predict(best.svm, newdata = testSet, decision.values = TRUE)
svm.pred.prob <- predict(best.svm, newdata = testSet, decision.values = TRUE, probability = TRUE)
mean(svm.pred == testSet$class)
plot(best.svm, testSet, pox ~ alm, xlim = c(-2, 2), ylim = c(-2,2))


#ensemble of 2 models
library(caret)
predDF <- data.frame(rf.pred, svm.pred, class = testSet$class, stringsAsFactors = F)
modelStack <- train(class ~., data = predDF, method = "nnet", metric = "Accuracy" )
summary(modelStack)

gbm_pred <- predict(modelStack, testSet)
mean(gbm_pred != testSet$class)

plot(modelStack)
trellis.par.set(caretTheme())
plot(modelStack, plotType = "level")

confusionMatrix(testSet$class, gbm_pred)
