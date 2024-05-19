-- --To get patient by gender --

SELECT Gender, COUNT(*) AS PatientCount
FROM PatientDemographics
GROUP BY Gender;
-- Average age

SELECT AVG(DATEDIFF(CURRENT_DATE, DOB) / 365) AS AverageAge
FROM PatientDemographics;

-- Most common health conditions by age group
SELECT 
    CASE
        WHEN AGE BETWEEN 0 AND 18 THEN '0-18'
        WHEN AGE BETWEEN 19 AND 35 THEN '19-35'
        WHEN AGE BETWEEN 36 AND 50 THEN '36-50'
        WHEN AGE BETWEEN 51 AND 65 THEN '51-65'
        ELSE '65+'
    END AS AgeGroup,
    Reason,
    COUNT(*) AS ConditionCount
FROM (
    SELECT 
        TIMESTAMPDIFF(YEAR, PD.DOB, CURDATE()) AS AGE,
        PD.PatientID,
        PA.Reason
    FROM PatientDemographics PD
    INNER JOIN PatientAdmissions PA ON PD.PatientID = PA.PatientID
) AS AgeAndCondition
GROUP BY AgeGroup, Reason
ORDER BY AgeGroup, ConditionCount DESC;

-- Determine the success rate of different treatments:

SELECT 
    Treatment,
    COUNT(*) AS TotalTreatments,
    SUM(CASE WHEN Outcome = 'Successful' THEN 1 ELSE 0 END) AS SuccessfulTreatments,
    SUM(CASE WHEN Outcome = 'Successful' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS SuccessRate
FROM TreatmentOutcomes
GROUP BY Treatment;

-- Analyze the distribution of treatment outcomes across genders or age groups:
-- Distribution across genders
SELECT 
    Gender,
    Outcome,
    COUNT(*) AS OutcomeCount
FROM PatientDemographics PD
JOIN PatientAdmissions PA ON PD.PatientID = PA.PatientID
JOIN TreatmentOutcomes TD ON PA.PatientID = TD.PatientID
GROUP BY Gender, Outcome;

-- Distribution across age groups
SELECT 
    CASE
        WHEN AGE BETWEEN 0 AND 18 THEN '0-18'
        WHEN AGE BETWEEN 19 AND 35 THEN '19-35'
        WHEN AGE BETWEEN 36 AND 50 THEN '36-50'
        WHEN AGE BETWEEN 51 AND 65 THEN '51-65'
        ELSE '65+'
    END AS AgeGroup,
    Outcome,
    COUNT(*) AS OutcomeCount
FROM (
    SELECT 
        TIMESTAMPDIFF(YEAR, PD.DOB, CURDATE()) AS AGE,
        Outcome
    FROM PatientDemographics PD
    JOIN PatientAdmissions PA ON PD.PatientID = PA.PatientID
    JOIN TreatmentOutcomes TD ON PA.PatientID = TD.PatientID
) AS AgeAndOutcome
GROUP BY AgeGroup, Outcome;

-- Identify trends in treatment effectiveness over time:

SELECT 
    YEAR(Date) AS Year,
    Outcome,
    COUNT(*) AS OutcomeCount
FROM TreatmentOutcomes
GROUP BY Year, Outcome
ORDER BY Year, Outcome;

-- Determine the most common reasons for patient admissions:
SELECT Reason, COUNT(*) AS AdmissionCount
FROM PatientAdmissions
GROUP BY Reason
ORDER BY AdmissionCount DESC;

-- Analyze the length of hospital stays for different conditions:
SELECT 
    Reason,
    AVG(DATEDIFF(DischargeDate, AdmissionDate)) AS AvgLengthOfStay
FROM PatientAdmissions
GROUP BY Reason;

-- Identify trends in patient admissions over time:
SELECT 
    YEAR(AdmissionDate) AS Year,
    MONTH(AdmissionDate) AS Month,
    COUNT(*) AS AdmissionCount
FROM PatientAdmissions
GROUP BY Year, Month
ORDER BY Year, Month;

-- Calculate the average number of patients treated by each doctor:

SELECT 
    DoctorID,
    COUNT(DISTINCT PatientID) AS PatientsTreated
FROM PatientAdmissions
GROUP BY DoctorID;

SELECT 
    AVG(PatientsTreated) AS AveragePatientsTreated
FROM (
    SELECT 
        DoctorID,
        COUNT(DISTINCT PatientID) AS PatientsTreated
    FROM PatientAdmissions
    GROUP BY DoctorID
) AS PatientCountsPerDoctor;


-- Determine the distribution of treatment outcomes for patients treated by each doctor:

SELECT 
    PA.DoctorID,
    TD.Outcome,
    COUNT(*) AS OutcomeCount
FROM PatientAdmissions PA
JOIN TreatmentOutcomes TD ON PA.PatientID = TD.PatientID
GROUP BY PA.DoctorID, TD.Outcome
ORDER BY PA.DoctorID, OutcomeCount DESC;

-- Identify doctors with the highest success rates in treating specific conditions:

SELECT 
    DoctorID,
    Treatment,
    COUNT(*) AS TotalTreatments,
    SUM(CASE WHEN Outcome = 'Successful' THEN 1 ELSE 0 END) AS SuccessfulTreatments,
    (SUM(CASE WHEN Outcome = 'Successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS SuccessRate
FROM (
    SELECT 
        PA.DoctorID,
        TD.Treatment,
        TD.Outcome
    FROM PatientAdmissions PA
    JOIN TreatmentOutcomes TD ON PA.PatientID = TD.PatientID
) AS TreatmentData
GROUP BY DoctorID, Treatment
ORDER BY SuccessRate DESC;

-- Analyze patient demographics and treatment outcomes by department:

SELECT 
    D.Department,
    PD.Gender,
    AVG(TIMESTAMPDIFF(YEAR, PD.DOB, CURDATE())) AS AverageAge,
    TD.Outcome,
    COUNT(*) AS OutcomeCount
FROM PatientDemographics PD
JOIN PatientAdmissions PA ON PD.PatientID = PA.PatientID
JOIN TreatmentOutcomes TD ON PA.PatientID = TD.PatientID
JOIN Doctors D ON PA.DoctorID = D.DoctorID
GROUP BY D.Department, PD.Gender, TD.Outcome
ORDER BY D.Department, PD.Gender, TD.Outcome;


-- Determine the average length of hospital stays and resource utilization rates for each department:
-- Average length of hospital stays by department
SELECT 
    D.Department,
    AVG(DATEDIFF(PA.DischargeDate, PA.AdmissionDate)) AS AvgLengthOfStay
FROM PatientAdmissions PA
JOIN Doctors D ON PA.DoctorID = D.DoctorID
GROUP BY D.Department;

-- Resource utilization rates by department
SELECT 
    D.Department,
    RU.ResourceType,
    AVG(RU.HoursUsed / RU.TotalHoursAvailable * 100) AS AvgUtilizationRate
FROM ResourceUtilization RU
JOIN PatientAdmissions PA ON RU.PatientID = PA.PatientID
JOIN Doctors D ON PA.DoctorID = D.DoctorID
GROUP BY D.Department, RU.ResourceType;

-- Identify departments with the highest patient satisfaction ratings:

SELECT 
    D.Department,
    AVG(PS.SatisfactionRating) AS AvgSatisfactionRating
FROM PatientSatisfaicc_world_cupicc_world_cupicc_world_cupicc_world_cupction PS
JOIN PatientAdmission PA ON PS.AdmissionID = PA.AdmissionID
JOIN Doctors D ON PA.DoctorID = D.DoctorID
GROUP BY D.Department
ORDER BY AvgSatisfactionRating DESC;
