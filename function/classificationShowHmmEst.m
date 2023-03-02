function classificationShowHmmEst(title_show,featureSet,r_result,cluster_K,test_alphaEst,test_tailEst,test_plotEst,leafOrder)

str={'negative';'positive'};
%% estTR

for r1=1:2
    
    r0=0;
    for r2=1:size(featureSet.hmm_result(r_result).estTR{r1,1},1)
        for r3=1:size(featureSet.hmm_result(r_result).estTR{r1,1},2)
            
            r0=r0+1;
            estTR_temp=featureSet.hmm_result(r_result).estTR{r1,1}{r2,r3};
            if featureSet.svm_result(r_result).inv
                estTR_temp=estTR_temp([2,1],[2,1]);
            end
            for r4=1:2
                for r5=1:2
                    
                    estTR{r1,1}{r4,r5}(r0,1)=estTR_temp(r4,r5);
                end
            end
        end
    end
end

for r1=1:2
    for r2=1:2
        for r3=1:2
            
            
            estTR_median{r1,1}(r2,r3)=median(estTR{r1,1}{r2,r3},1);
            estTR_mean{r1,1}(r2,r3)=mean(estTR{r1,1}{r2,r3},1);
            estTR_std{r1,1}(r2,r3)=std(estTR{r1,1}{r2,r3},0,1);
        end
    end
end

p_TR=zeros(2,2);
for r1=1:2
    for r2=1:2
        
        x=estTR{1,1}{r1,r2};
        y=estTR{2,1}{r1,r2};
        
        if strcmp(test_tailEst,'ftest')
            [p_TR(r1,r2),~,~]=anova1([x,y],{'1','2'},'off');
        else
            [~,p_TR(r1,r2),~,~]=ttest2(x,y,'Tail',test_tailEst,'Vartype','unequal');
        end
    end
end

for r1=1:2
    
    figure
    subplot(2,2,1);
    imagesc(estTR_median{r1,1});
    axis off;
    colorbar;
    caxis([0,1]);
    colorbar off;
    
    subplot(2,2,2);
    imagesc(estTR_mean{r1,1});
    axis off;
    colorbar;
    caxis([0,1]);
    colorbar off;
    
    subplot(2,2,3);
    imagesc(estTR_std{r1,1});
    axis off;
    colorbar;
    caxis([0,1]);
    colorbar off;
    
    if title_show
        suptitle([str{r1,1} ' subject(s) estTR']);
        
        figure
        subplot(2,2,1);
        plot(0,0);box off;axis off;
        title({'median:';num2str(estTR_median{r1,1})});
        
        subplot(2,2,2);
        plot(0,0);box off;axis off;
        title({'mean:';num2str(estTR_mean{r1,1})});
        
        subplot(2,2,3);
        plot(0,0);box off;axis off;
        title({'std:';num2str(estTR_std{r1,1})});
        
        subplot(2,2,4);
        plot(0,0);box off;axis off;
        title({'p value:';num2str(p_TR)});
    end
end
%% estE

for r1=1:2
    
    r0=0;
    for r2=1:size(featureSet.hmm_result(r_result).estE{r1,1},1)
        for r3=1:size(featureSet.hmm_result(r_result).estE{r1,1},2)
            
            r0=r0+1;
            estE_temp=featureSet.hmm_result(r_result).estE{r1,1}{r2,r3};
            if featureSet.svm_result(r_result).inv
                estE_temp=estE_temp([2,1],:);
            end
            for r4=1:2
                
                estE{r1,r4}(r0,:)=estE_temp(r4,:);
            end
        end
    end
end

for r1=1:2
    for r2=1:2
        
        estE_mean{r1,r2}=mean(estE{r1,r2},1);
        estE_std{r1,r2}=std(estE{r1,r2},0,1);
    end
end

p_E=zeros(1,cluster_K);
for r=1:cluster_K
    
    x=estE{1,1}(:,r);
    y=estE{2,2}(:,r);
    
    if strcmp(test_tailEst,'ftest')
        [p_E(1,r),~,~]=anova1([x,y],{'1','2'},'off');
    else
        [~,p_E(1,r),~,~]=ttest2(x,y,'Tail',test_tailEst,'Vartype','unequal');
    end
end

if cluster_K~=length(leafOrder)
    leafOrder=1:cluster_K;
end


for r1=1:2
    for r2=1:2
        
        figure
        plot([0 cluster_K+1],[0 0],'k','LineWidth',2)
        hold on;
        plot([0 cluster_K+1],[1 1],'--k','LineWidth',2)
        hold on;
        
        if strcmp(test_plotEst,'bar')
            bar(estE_mean{r1,r2}(1,leafOrder),'FaceColor','none');
            for r3=1:cluster_K
                
                hold on;
                plot([r3 r3],[estE_mean{r1,r2}(1,leafOrder(r3)) estE_mean{r1,r2}(1,leafOrder(r3))+estE_std{r1,r2}(1,leafOrder(r3))],'k','LineWidth',2);
                hold on;
                plot([r3-0.15 r3+0.15],[estE_mean{r1,r2}(1,leafOrder(r3))+estE_std{r1,r2}(1,leafOrder(r3)) estE_mean{r1,r2}(1,leafOrder(r3))+estE_std{r1,r2}(1,leafOrder(r3))],'k','LineWidth',2);
            end
            set(gca,'XTick',1:cluster_K,'XTickLabel',leafOrder);
            
        elseif strcmp(test_plotEst,'box')
            boxplot(estE{r1,r2}(:,leafOrder),'Labels',leafOrder,'colors','k','Notch','off','plotstyle','compact','boxstyle','outline','medianstyle','target');
        end
        xlim([0,cluster_K+1]);
        ylim([-0.2,1.1]);
        box off;
        
        if r1==2 && r2==2
            for r3=1:cluster_K
                
                if p_E(leafOrder(r3))<test_alphaEst
                    hold on;
                    plot(r3,-0.1,'Marker','*','MarkerEdgeColor','k');
                end
            end
        end
        
        if title_show
            suptitle([str{r1,1} ' subject(s), ' str{r2,1} ' estE']);
        end
    end
end

if title_show
    figure
    suptitle({[str{1,1} ' subject(s), ' str{1,1} ' estE'];[str{2,1} ' subject(s), ' str{2,1} ' estE']});
    plot(0,0);box off;axis off;
    text(-0.25,0,{'center No. & p value:';num2str([leafOrder',p_E(leafOrder)'])});
end
end