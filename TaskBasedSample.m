function [outputTable] = TaskBasedSample(inputTable, inputTarget, threshold, mkFigures)
% Function to run optimized quota sampling algorithm
% Author: Natalie Baughan, MIDRC TDP 3d
% Contact: nbaughan@uchicago.edu
% Date: March 2023

% Split inputTarget into categories
Atarget = inputTarget(1:9);
Rtarget = inputTarget(10:16);
Starget = inputTarget(17:20);
Etarget = inputTarget(21:23);
Ctarget = inputTarget(24:26);

% Score each case
maxperc = 1;
ntrials = 0;
j = 1;

while maxperc > threshold
    if ntrials > 0
        % Sequentially remove max score patients
        inputTable = sortrows(inputTable,'score','descend');
        % Remove 1% of patients or 5 patients, whichever is greater
        numToRemove = max(round(height(inputTable)*0.01),5);
        inputTable(1:numToRemove, :) = [];
    end

    ntrials = ntrials + 1;
    
    [A,R,S,E,C] = CountTBSCategories(inputTable);
    
    % Age
    A.Adif = A.Percent - Atarget;
    
    % Race
    R.Rdif = R.Percent - Rtarget;
    
    % Sex
    S.Sdif = S.Percent - Starget;
    
    % Ethnicity
    E.Edif = E.Percent - Etarget;
    
    % COVID
    C.Cdif = C.Percent - Ctarget;
    
    inputTable.score = zeros(height(inputTable),1);
    
    for i = 1:height(inputTable)
        for agegroup = 1:height(A)
            if inputTable.agec(i) == agegroup
                inputTable.score(i) = inputTable.score(i) + A.Adif(agegroup);
            end
        end 
        
        for racegroup = 1:height(R)
            if inputTable.race(i) == R.race(racegroup)
                inputTable.score(i) = inputTable.score(i) + R.Rdif(racegroup);
            end
        end 
        
        for sexgroup = 1:height(S)
            if inputTable.sex(i) == S.sex(sexgroup)
                inputTable.score(i) = inputTable.score(i) + S.Sdif(sexgroup);
            end
        end 
        
        for ethnicitygroup = 1:height(E)
            if inputTable.ethnicity(i) == E.ethnicity(ethnicitygroup)
                inputTable.score(i) = inputTable.score(i) + E.Edif(ethnicitygroup);
            end
        end 
        
        for covidgroup = 1:height(C)
            if inputTable.covid19_positive(i) == C.covid19_positive(covidgroup)
                inputTable.score(i) = inputTable.score(i) + C.Cdif(covidgroup);
            end
        end 
    end
    
    maxperc = max([max(abs(A.Adif)),max(abs(R.Rdif)),max(abs(S.Sdif)),max(abs(E.Edif)),max(abs(C.Cdif))]);
    maxpercvec(ntrials) = max([max(abs(A.Adif)),max(abs(R.Rdif)),max(abs(S.Sdif)),max(abs(E.Edif)),max(abs(C.Cdif))]);
    inputTablesize(ntrials) = height(inputTable);


    if mkFigures == 1
        if ntrials == 10 ||  ntrials == 50
            subplot(3,1,j)
            histogram(inputTable.score)
            title("Optimization iteration number " + ntrials)
            xlabel("Spread of patient demographic-fit deviation metrics")
            xlim([-0.5 0.5])
            j = j + 1;
        end
    end
    

end

outputTable = inputTable;

if mkFigures == 1
    subplot(3,1,3)
    histogram(outputTable.score)
    title("Optimization iteration number " + ntrials + " (final)")
    xlabel("Spread of patient demographic-fit deviation metrics")
    xlim([-0.5 0.5])
    
    figure
    plot(linspace(1,ntrials,ntrials),maxpercvec, 'b','LineWidth',2)
    title('Maximum task-demographic deviation metric')
    xlabel('Optimization iteration')
    ylabel('Maximum percent deviation in any category')
    figure
    plot(linspace(1,ntrials,ntrials),inputTablesize)
    title('Resultant sample size')
    xlabel('Optimization iteration number'), ylabel('Sample size')
end


end