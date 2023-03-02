function [predict_label,nosvm_model]=nosvmClassifier(r_classifier,trainORtest,train_data,train_label,test_data,test_label,nTree,hiddenLayerSize,trainFcn,splitRate,nosvm_model,featurePlot,lineWidth,yLimError,yLimMargin,yLimImportance)

predict_label=[];
if r_classifier==0
    predict_label=test_label;
    nosvm_model=[];
elseif r_classifier==1
    if trainORtest==1
        [nSample_train,nFeature]=size(train_data);
        nosvm_model=TreeBagger(nTree,train_data,train_label,'oobpred','on','OOBVarimp','on');
        
        predict_label_train=nosvm_model.oobPredict;
        predict_label_train=str2num(cell2mat(predict_label_train));
        
        accAll_train=zeros(nSample_train,1);
        for r=1:nSample_train
            
            accAll_train(r,1)=double(train_label(r,1)==predict_label_train(r,1));
        end
        acc_train=sum(accAll_train)/nSample_train;
        
        if featurePlot==1
            figure
            
            subplot(2,2,1)
            plot(oobError(nosvm_model),'LineWidth',lineWidth);
            xlim([1 nTree]);
            if sum(abs(yLimError))~=0
                ylim(yLimError);
            end
            xlabel('Number of Grown Trees');
            ylabel('Out-of-Bag Classification Error');
            
            subplot(2,2,3)
            plot(oobMeanMargin(nosvm_model),'LineWidth',lineWidth);
            xlim([1 nTree]);
            if sum(abs(yLimMargin))~=0
                ylim(yLimMargin);
            end
            xlabel('Number of Grown Trees');
            ylabel('Out-of-Bag Mean Classification Margin');
            
            subplot(1,2,2)
            bar(nosvm_model.OOBPermutedVarDeltaError);
            xlim([0.5 nFeature+0.5]);
            if sum(abs(yLimImportance))~=0
                ylim(yLimImportance);
            end
            xlabel('Feature Index');
            ylabel('Out-of-Bag Feature Importance');
            title(['train accuracy: ' num2str(acc_train*100) '%']);
        end
    elseif trainORtest==2
        
        predict_label=nosvm_model.predict(test_data);
        predict_label=str2num(cell2mat(predict_label));
    end
elseif r_classifier==2
    if trainORtest==1
        % Create a Pattern Recognition Network
        net=patternnet(hiddenLayerSize, trainFcn);
        
        % Setup Division of Data for Training, Validation, Testing
        net.divideParam.trainRatio=1-splitRate;
        net.divideParam.valRatio=splitRate;
        net.divideParam.testRatio=0;
        
        % Train the Network
        x=train_data';
        nSample_train=size(x,2);
        
        t=size(2,nSample_train);
        for r=1:nSample_train
            
            t(train_label(r,1)+1,r)=1;
        end
        [nosvm_model,tr]=train(net,x,t);
        
        if featurePlot==0
            nntraintool('close');
        end
        
        if featurePlot==1
            % Test the Network
            y=nosvm_model(x);
            e=gsubtract(t,y);
            
            % View the Network
            % view(net);
            
            % Plots
            % Uncomment these lines to enable various plots.
            figure
            plotperform(tr);
            figure
            plottrainstate(tr);
            figure
            ploterrhist(e);
            figure
            plotconfusion(t,y);
            figure
            plotroc(t,y);
        end
    elseif trainORtest==2
        % Test the Network
        x=test_data';
        nSample_test=size(x,2);
        
        y=nosvm_model(x);
        
        predict_label=size(nSample_test,1);
        for r=1:nSample_test
            
            if y(1,r)<y(2,r)
                predict_label(r,1)=0;
            else
                predict_label(r,1)=1;
            end
        end
    end
end
end