degrade_4hr = [4
5
4
7
5
7
2
6
6
5
4
2
6
2
6
3
3
4
6
3
7
6
5
3
3
4
6
3
6
6
6
6
7
2
4
0
6
7
1
7
2
2
4
5
6
7
3
2
5
2
6
5
5
6
6
4
5
1
5
5
6
0
5
4
6
3
4
2
4
7
2
5
5
5
5
2
4
2
5
2
7
6
5
7
4
6
6
4
4
3
6
7
4
5
6
7
7
7
1
0];

degrade_124hr = [1
3
5
2
2
2
2
2
1
4
1
0
0
0
2
0
5
1
4
1
1
2
5
0
1
3
1
0
5
6
3
2
4
1
2
0
2
4
1
2
1
0
0
0
4
6
1
2
4
1
1
4
6
5
1
5
2
0
0
0
4
0
3
1
4
2
2
0
2
2
3
2
7
3
1
0
1
2
1
4
5
4
1
3
1
1
3
1
2
3
1
3
1
0
1
5
0
5
0
0];

replenish_4hr = [7
7
7
6
7
6
2
4
6
7
6
4
6
7
7
6
7
7
5
7
5
7
4
7
7
7
7
6
6
4
3
4
6
7
5
6
7
6
7
7
7
5
6
7
6
3
6
6
7
4
7
3
6
6
7
7
5
7
6
5
7
5
7
6
6
7
6
4
7
7
7
5
5
2
6
6
7
6
6
7
7
6
6
6
7
6
7
6
7
5
7
6
5
7
4
7
6
6
6
6];

replenish_124hr = [6
7
7
6
7
6
2
5
6
6
6
4
6
7
7
7
6
7
5
7
6
7
3
7
7
5
7
6
6
4
3
5
7
7
4
6
7
6
6
5
6
7
4
6
6
2
7
6
5
6
7
4
6
5
7
7
5
7
6
5
7
6
6
6
6
7
3
4
7
7
6
5
4
2
6
6
7
6
5
7
7
4
6
6
7
6
7
7
7
5
7
7
5
7
6
7
6
6
6
7];

pilfer_4hr = [5
5
1
2
6
2
6
4
7
3
6
3
4
5
5
4
4
4
5
4
6
6
5
7
4
4
6
4
5
4
4
5
7
6
7
4
5
4
5
6
6
6
3
6
6
5
5
6
5
5
2
4
7
4
5
5
1
6
2
4
4
6
5
6
5
1
5
4
7
7
7
6
6
4
6
6
5
4
5
7
6
4
4
6
4
5
3
4
4
4
7
1
5
7
5
3
3
7
2
4];

pilfer_124hr = [3
5
1
2
2
2
2
3
4
1
5
5
0
5
2
1
5
5
6
5
6
6
7
7
2
5
5
6
4
0
4
0
7
5
7
5
5
2
5
4
3
6
3
6
6
5
5
2
2
5
1
5
3
4
3
6
0
5
3
3
0
2
4
3
0
1
2
3
4
5
4
3
4
4
6
0
4
1
3
7
2
2
1
5
3
3
6
3
3
6
5
4
5
2
2
2
3
7
1
5];

type = ['4 HR '];
type2 = ['124 HR '];
avg_side_preference4 = [mean(degrade_4hr);
                        mean(replenish_4hr);
                        mean(pilfer_4hr)];
                    
avg_side_preference124 = [mean(degrade_124hr);
                            mean(replenish_124hr);
                            mean(pilfer_124hr)];
                        
sem1=std(degrade_4hr)/sqrt(length(degrade_4hr))
sem2 = std(degrade_124hr)/sqrt(length(degrade_124hr))
sem3 = std(replenish_4hr)/sqrt(length(replenish_4hr))
sem4 = std(replenish_124hr)/sqrt(length(replenish_124hr))
sem5 = std(pilfer_4hr)/sqrt(length(pilfer_4hr))
sem6 = std(pilfer_124hr)/sqrt(length(pilfer_124hr))
sem4 = [sem1;
        sem3;
        sem5];
sem124 = [sem2;
            sem4;
            sem6];
    
    for cond=1:3
        %l = 2*k;
        %     temp(l-1) = avg_side_preference(k);
        %     e(l-1) = error(k);
        temp(cond, 1) = 7 - avg_side_preference4(cond);
        temp(cond, 2) = avg_side_preference4(cond);
        e(cond, 1) = sem4(cond);
        e(cond, 2) = sem4(cond);
    end
    

avg_side_preference = temp;
error = e;

%for i = 1:2
    figure;
    barwitherr(error, avg_side_preference);
    set(gca,'XTickLabel',{'Degrade','Replenish','Pilfer'});
    legend('peanut','worm');
    ylabel('Avg Number of Checks');
    title_message = '4 HR Side Preference';
    title(title_message);
%end

    for cond = 1:3
        temp(cond, 1) = 7 - avg_side_preference124(cond);
        temp(cond, 2) = avg_side_preference124(cond);
        e(cond, 1) = sem4(cond);
        e(cond, 2) = sem4(cond);
    end
    
    
avg_side_preference = temp;
error = e;

%for i = 1:2
    figure;
    barwitherr(error, avg_side_preference);
    set(gca,'XTickLabel',{'Degrade','Replenish','Pilfer'});
    legend('peanut','worm');
    ylabel('Avg Number of Checks');
    title_message = '124 HR Side Preference';
    title(title_message);
%end
