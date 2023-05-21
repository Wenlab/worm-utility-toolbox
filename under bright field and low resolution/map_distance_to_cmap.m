function cmap_with_dist=map_distance_to_cmap(dist,cmap)
% compute the linear mapping distance to the given cmap. This function
% doesn't distinguish positve or negtive distinces.
range=max(dist);
ruler=linspace(0,range,height(cmap));
for i=1:length(dist)
    rank_of_value=compare_value(dist(i),ruler);
    cmap_with_dist(i,:)=cmap(rank_of_value,:);
end
end


function rank_of_value=compare_value(value,ruler)
for i=1:length(ruler)-1
    if value>=ruler(i) && value<=ruler(i+1)
        rank_of_value=i;
        break
    end
end
end