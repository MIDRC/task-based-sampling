function [A,R,S,E,C] = CountTBSCategories(InputTable)
% Function to count Age, Race, Sex, Ethnicity, and COVID status info
% Returns data as 5 tables with categories and order corresponding to the
% standard target specification file "MIDRC_TaskBasedSample_TargetSpecification.xlsx"
% Author: Natalie Baughan, MIDRC TDP 3d
% Contact: nbaughan@uchicago.edu
% Date: March 2023

% Assume 0-17, 18-29, 30-39, 40-49, 50-64, 65-74, 75-84, 85+
A = groupcounts(InputTable,'age_at_index',[0 18 30 40 50 65 75 85 140 1000],'IncludeEmptyGroups',true,'IncludeMissingGroups',true);
A = renamevars(A,"disc_age_at_index","agec");
A.Percent = A.Percent./100;

Rsum = [sum(InputTable.race == 'American Indian or Alaska Native');...
    sum(InputTable.race == 'Asian'); sum(InputTable.race == 'Black or African American');...
    sum(InputTable.race == 'Native Hawaiian or other Pacific Islander'); ...
    sum(InputTable.race == 'Not Reported');sum(InputTable.race == 'Other'); ...
    sum(InputTable.race == 'White')];
race = ["American Indian or Alaska Native";"Asian";"Black or African American";"Native Hawaiian or other Pacific Islander";"Not Reported";"Other";"White"];
R = table(race,Rsum,Rsum./sum(Rsum));
R = renamevars(R,["Rsum","Var3"],["GroupCount","Percent"]);

Ssum = [sum(InputTable.sex == 'Female'); sum(InputTable.sex == 'Male');...
    sum(InputTable.sex == 'Other'); sum(InputTable.sex == 'Not Reported')];
sex = ["Female";"Male";"Other";"Not Reported"];
S = table(sex,Ssum,Ssum./sum(Ssum));
S = renamevars(S,["Ssum","Var3"],["GroupCount","Percent"]);

Esum = [sum(InputTable.ethnicity == 'Hispanic or Latino'); ... 
    sum(InputTable.ethnicity == 'Not Hispanic or Latino'); ...
    sum(InputTable.ethnicity == 'Not Reported')];
ethnicity = ["Hispanic or Latino";"Not Hispanic or Latino";'Not Reported'];
E = table(ethnicity,Esum,Esum./sum(Esum));
E = renamevars(E,["Esum","Var3"],["GroupCount","Percent"]);

Csum = [sum(InputTable.covid19_positive == 'No'); ...
    sum(InputTable.covid19_positive == 'Not Reported');...
    sum(InputTable.covid19_positive == 'Yes')]; 
covid19_positive = ["No";"Not Reported";"Yes"];
C = table(covid19_positive,Csum,Csum./sum(Csum));
C = renamevars(C,["Csum","Var3"],["GroupCount","Percent"]);

end

