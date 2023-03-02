function h=process_featureShowEEGfeature(EEG_feature,r_channel,meth,C_range,colorbar_show,title_show,Title)

str={' morphology_o_p_e_n';' morphology_c_l_o_s_e'};
switch meth
    case {'bandPower';'morphology';'CFC_bandPowerRate';'CFC_morphologyRate';'timeFeature';'morphTimeFeature'}
        h=plot_scalp(EEG_feature,r_channel,colorbar_show,title_show,Title,str,C_range);
    otherwise
        h=plot_corr(EEG_feature,r_channel,colorbar_show,title_show,Title,str);
end
end
%%

function h=plot_scalp(EEG_feature,r_channel,colorbar_show,title_show,Title,str,C_range)

AmC=1.03;
res=1000;
rRange=1.2;

load(['scalp(' num2str(size(EEG_feature{1,1},2)) ').mat']);

x=AmC*coordinate(:,1)';
y=AmC*coordinate(:,2)';

cmin=C_range(1);
cmax=C_range(2);

[X,Y]=meshgrid(-rRange:2*rRange/res:rRange,-rRange:2*rRange/res:rRange);

n_feature=size(EEG_feature,1);
h=zeros(n_feature,1);
for r1=1:n_feature
    
    if ~coordinate_size
        z=EEG_feature{r1,1};
        Z=griddata(x,y,z,X,Y,'natural');
        
        [n1,n2]=size(Z);
        for r2=1:n1
            for r3=1:n2
                if X(r2,r3)^2+Y(r2,r3)^2>1^2
                    Z(r2,r3)=NaN;
                end
            end
        end
        
        h(r1,1)=figure;
        surf(X,Y,Z,'EdgeColor','none');
        view(0,90);
    else
        z=EEG_feature{r1,1};
        
        h(r1,1)=figure;
        colormap_temp=colormap;
        n_colormap_temp=length(colormap_temp);
        r_colormap_temp=min(floor(n_colormap_temp*(z-cmin)/(cmax-cmin)),n_colormap_temp);
        r_colormap_temp=max(r_colormap_temp,1);
        % scatter3(x,y,z,10*coordinate_size,colormap_temp(r_colormap_temp,:),'filled');
        for r2=1:size(coordinate,1)
            
            if z(r2)>=cmin
                hold on;
                plot3(x(r2),y(r2),z(r2),'o','MarkerSize',coordinate_size,'MarkerFaceColor',colormap_temp(r_colormap_temp(r2),:),'MarkerEdgeColor',colormap_temp(r_colormap_temp(r2),:));
            end
        end
        view(0,90);
    end
    axis off;
    colorbar;
    caxis([cmin cmax]);
    if ~colorbar_show
        colorbar off;
    end
    
    scalp_outline(res,cmax);
    if ~coordinate_size || coordinate_size>8
        for r2=1:size(coordinate,1)
            
            hold on;
            if ismember(r2,r_channel)
                plot3(coordinate(r2,1),coordinate(r2,2),cmax,'o','MarkerSize',8,'MarkerFaceColor','w','MarkerEdgeColor','k','LineWidth',2);
            else
                plot3(coordinate(r2,1),coordinate(r2,2),cmax,'o','MarkerSize',4,'MarkerFaceColor','k','MarkerEdgeColor','k');
            end
        end
    end
    axis([-rRange rRange -rRange rRange]);
    axis equal;
    axis off;
    
    if title_show
        if n_feature==1
            title(Title);
        else
            title([Title str{r1,1}]);
        end
    end
end
end
%%

function h=plot_corr(EEG_feature,r_channel,colorbar_show,title_show,Title,str)

n_feature=size(EEG_feature,1);
h=zeros(n_feature,1);
for r1=1:n_feature
    
    h(r1,1)=figure;
    imagesc(EEG_feature{r1,1});
    if ~isempty(r_channel)
        
        [n1,n2]=size(EEG_feature{r1,1});
        for r2=r_channel
            
            hold on;
            plot([0.5 n1+0.5],[r2+0.5 r2+0.5],'k');
            hold on;
            plot([0.5 n1+0.5],[r2-0.5 r2-0.5],'k');
            hold on;
            plot([r2+0.5 r2+0.5],[0.5 n2+0.5],'k');
            hold on;
            plot([r2-0.5 r2-0.5],[0.5 n2+0.5],'k');
        end
    end
    colorbar;
    caxis([-1,1]);
    if ~colorbar_show
        colorbar off;
    end
    axis equal;
    axis off;
    
    if title_show
        if n_feature==1
            title(Title);
        else
            title([Title str{r1,1}]);
        end
    end
end
end