function anova = two_way_anova(feat,lab)

% feat = feat_ecg_time_zs;
% lab = batch_lab(:,1);

[R,C] = size(feat);
feat_reshape = reshape(feat,[R*C,1])';
group1 = repmat(lab,C,1); % challenge
group2 = reshape(repmat(1:C,R,1),[R*C,1])'; % feat

% [anova.p,anova.tbl,anova.stats,anova.terms] = anovan(feat_reshape,{group1,group2},'model','interaction','varnames',{'challenges','features'},'display','off');
[anova.p,anova.tbl,anova.stats,anova.terms] = anovan(feat_reshape,{group1,group2},'display','off');
[anova.c,anova.mean,anova.h,anova.gnames] = multcompare(anova.stats,'Display','off');
