USE master;
ALTER AUTHORIZATIon on DATABasE::UniversityResearchSystem TO sa;

use UniversityResearchSystem
/*
Question 1 (1 Points) 
Write a query to display all researchers along with the projects they work on. Include 
researchers who are not currently working on any project. 
*/

select 
	r.Id as ResearchID,
	ConCAT(r.FirstName,' ',r.MiddleName,' ',r.LastName) As ResearchName,
	r.Email As ReserchEmail,
	P.Title As ProjectTitle,
	p.StartDate As 'Project StartDate',
	p.EndDate As 'Project endDate',
	w.Role As Role,
	w.HoursPerWeek as HoursPerWeek

from Researcher r
left join WorksOn w on r.Id = w.ResearcherId
left join ResearchProject p on p.Id = w.ProjectId 

/*Question 2 (1 Points) 
List all research projects with their lead researcher's full name and email. Show only projects 
that have at least one grant funding them. 
*/

select Distinct 
	p.Id ,
	p.Title As ProjectTitle,
	p.Budget As 'Project Budget',
	p.Status As 'Project Status',
	p.StartDate As 'Project StartDate' ,
	p.StartDate As 'Project EndDate',
	ConCAT(r.FirstName,' ',r.MiddleName,' ',r.LastName) As ResearchName,
	r.Email As ReserchEmail

from ResearchProject p
join Researcher r on p.LeaderId = r.Id
join Funds f on p.Id = f.ProjectId


/*Question 3 (1 Points) 
Write a query to show all possible combinations of researchers and publications. Then explain 
why this might be a bad idea for a production query. 
*/

select *
from Researcher r
cross join Publication p 

/*Question 4 (1 points) 
Display all researchers who supervise others, along with the names of researchers they 
supervise. Include the supervision start date and role. 
*/

select 
	ConCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName) As [SuperVisor Name],
	ConCAT(r.FirstName,' ',r.MiddleName,' ',r.LastName) As [SuperVised Name],
	Sup.Role as [Role],
	Sup.SupervisionStartDate as [Supervision Start Date]

from Researcher s
join Supervises Sup on s.Id = Sup.SupervisorId
join Researcher r on Sup.SupervisedId = r.Id


/*Question 5 (1 Points) 
Write a query to find all researchers who have published papers but are NOT currently working 
on any active project. 
*/

select *
from Researcher r
join Publishes p on r.Id = p.ResearcherId
where r.Id Not in (
	select w.ResearcherId from WorksOn w
)

/*Question 6 (1 Points) 
Retrieve the five most-cited publications, ensuring that any publications sharing the same 
citation count as the fifth-ranked entry are also included.
*/

select Top 5 With Ties 
	p.Id,
	p.Title,
	p.CitationCount

from Publication p
order by p.CitationCount DESC


/*Question 7 (1 Points) 
Retrieve researchers ordered by last name, displaying the second page of results with 10 
records per page.
*/

select *
from Researcher r
order by r.LastName
offset 10 Rows
Fetch next 10 Rows only

/* 
Question 8 (1.5 Points) 
Compare the results of: 
select TOP 3 *  
from Researcher 
ORDER BY LastName  
Versus 
select *  
from Researcher  
ORDER BY LastName  
OFFSET 0 ROWS FETCH NEXT 3 ROWS onLY 
Are they functionally identical? What are the advantages of OFFSET-FETCH over TOP?
*/ 

-- Are they functionally identical?
-- Yes [ The Same Result ]

-- What are the advantages of OFFSET-FETCH over TOP?
-- I think The advantage is :
--                           1- OFFSET-FETCH Require [order by] , TOP Not Require ( the Result Change )
--                           2- OFFSET-FETCH use in pagentation Effectively

-- ################################################################################################## 

/*Question 9 (1 Points) 
Assign a unique sequential index to each researcher within the same building, ordered by date 
of birth from oldest to youngest. 
*/

Select ROW_NUMBER() OVER (Partition by building ORDER BY DateOfBirth desc ) as [sequential index],
	ConCAT(r.FirstName,' ',r.MiddleName,' ',r.LastName) As [Name],
	r.Building as Building,
	r.DateOfBirth as DateOfBirth

from Researcher r


/*Question 10 (1 Points) 
Rank publications within each publication type (Journal or Conference) based on their citation 
count, and display the publication title, type, citation count, and rank.
*/
select Rank() OVER (Partition by [Type] ORDER BY CitationCount desc ) as [Rank],
	p.Title,
	p.Type,
	p.CitationCount

from Publication p

/*Question 11 (1 Points) 
Rank research projects by their budget within each status category, then explain how ranking 
with gaps differs from ranking without gaps. 
*/
select  RANK() OVER (PARTITIon BY p.Status ORDER BY p.Budget DESC) as [Rank],
    p.Id,
    p.Title,
    p.Status,
    p.Budget
   
from ResearchProject p;


/*Question 12 (1 Points) 
Divide researchers into four equal groups based on the number of publications they have 
authored, and display each researcher’s ID, name, publication count, and group number. 
*/

select NTILE(4) OVER (ORDER BY t.co DESC) as [Group],
	r.Id,
	ConCAT(r.FirstName,' ',r.MiddleName,' ',r.LastName) As [Name],
	t.co as [Count]

from Researcher r
join (
	select p.ResearcherId ,COUNT(P.PublicationId) as co
	from Publishes p
	group by p.ResearcherId
	) as t
on t.ResearcherId = r.Id


/*Question 13 (1 Points) 
Explain the logical execution order of the following query clauses: select, from, where, 
group by, HAVING, ORDER BY, TOP/OFFSET-FETCH. 
*/

/*
 * 1- from
 * 2- where
 * 3- group by
 * 4- HAVING
 * 5- select
 * 6- ORDER BY
 * 7- TOP/OFFSET-FETCH.
 */


 /*Question 14 (1 Points) 
Given this query, explain why it produces an error and how to fix it: 
select ResearcherId, COUNT(*) as ProjectCount 
from WorksOn  
where ProjectCount > 2 group by ResearcherId
 */

select ResearcherId, COUNT(*) --as ProjectCount 
from WorksOn  
--where ProjectCount > 2 
group by ResearcherId
having COUNT(*) > 2

-- The Problem is Exceution Order 
-- So We Use Having insted of where 
-- And aggregate function itself in having ( Not The alies )

/*Question 15 (1 Points) 
Write a query to display each researcher's full name (FirstName + MiddleName + LastName) as 
a single column, their email in lowercase, and their age in years. 
*/

select
	ConCAT(r.FirstName,' ',r.MiddleName,' ',r.LastName) As [Name],
	LOWER(r.Email) Email,
	DATEDifF(YEAR,R.DateOfBirth,SYSDATETIME()) as AGE

from Researcher r

/*Question 16 (1 Points) 
For each research project, calculate the duration in days between StartDate and EndDate (or 
current date if EndDate is NULL). Also show the month and year when the project started. 
*/

select 
	DATEDifF(DAY, p.StartDate,ISNULL(P.Enddate,SYSDATETIME())) [duration in days],
	MonTH(p.StartDate) [Start Month],
    YEAR(p.StartDate) [Start Year]

from ResearchProject p

/*Question 17 (1 Points) 
Write a query to find all researchers whose email domain (part after @) is 'university.edu'. 
*/

select *
from Researcher r
where r.Email like '%@university.edu%'

/*Question 18 (1 Points) 
Display researcher details, substituting 'N/A' wherever the MiddleName or RoomNumber is 
missing. 
*/

select 
	r.Id,
	r.FirstName,
	isnull(r.MiddleName,'N/A') MiddleName,
	r.LastName,
	r.Email,
	r.DateOfBirth,
	r.Building,
	isnull(r.RoomNumber,'N/A') RoomNumber

from Researcher r

/*Question 19 (1 Points) 
Write a query to classify projects into categories based on their budget: 'Small' for budgets 
under 50,000, 'Medium' for budgets between 50,000 and 150,000, and 'Large' for budgets 
exceeding 150,000. 
*/

select
    p.Id,
    p.Title,
    p.Budget,
    CasE
        WHEN p.Budget < 50000 THEN 'Small'
        WHEN p.Budget BETWEEN 50000 AND 150000 THEN 'Medium'
        WHEN p.Budget > 150000 THEN 'Large'
    END as ProjectCategory
from ResearchProject p;

/*Question 20 (1 Points)
Calculate the total budget managed by each researcher who leads one or more projects, and 
display their full name alongside this total. 
*/

select 
	ConCAT(r.FirstName,' ',r.MiddleName,' ',r.LastName) As [Name],
	SUM(P.Budget)
from Researcher r
join ResearchProject p on p.LeaderId =r.Id
Group by r.Id ,r.FirstName,r.MiddleName,r.LastName

/*Question 21 (1 Points) 
Display the number of researchers in each building, but only for buildings that have more than 3 
researchers.
*/

select r.Building,COUNT(r.Id) as [number of researchers]
from Researcher r
group by r.Building
Having COUNT(r.Id) > 3

/*Question 22 (1 Points) 
For each publication type, calculate the average citation count, total citations, and number of 
publications. Filter to show only types with an average citation count above 50. 
*/

select p.Type , AVG(p.CitationCount),Sum(p.CitationCount),Count(p.Id)
from Publication p
group by p.Type
Having AVG(p.CitationCount) > 50

/*Question 23 (1 Points) 
Find researchers who work on more than 2 projects and have a total weekly hour commitment 
exceeding 60 hours. Show ResearcherId, project count, and total hours. 
*/

select 
	r.Id [ResearcherId],
	COUNT(w.ProjectId) [project count],
	SUM(w.HoursPerWeek) [total hours]

from Researcher r
join WorksOn w on w.ResearcherId = r.Id
Group by r.Id
Having SUM(w.HoursPerWeek) > 60

/*Question 24 (1 Points) 
Write a query using a subquery to find all projects that have a budget greater than the average 
budget of all projects.
*/

select * 
from ResearchProject p
where p.Budget > (
		select AVG(Budget)
		from ResearchProject
)

/*Question 25 (1 Points) 
Write a query using a subquery to find researchers who have more publications than the 
average number of publications for researchers in the same building. 
*/

select 
    r.Id,
    ConCAT(r.FirstName,' ',r.MiddleName,' ',r.LastName) as [Name],
    r.Building
from Researcher r
join Publishes p 
    on p.ResearcherId = r.Id
group by 
    r.Id, r.FirstName, r.MiddleName, r.LastName, r.Building
having 
    COUNT(p.PublicationId) >
    (
        select AVG(pub_count)
        from (
            select COUNT(p2.PublicationId) as pub_count
            from Researcher r2
            join Publishes p2 
                on p2.ResearcherId = r2.Id
            where r2.Building = r.Building
            group by r2.Id
        ) t
);
-- in this i use ai tool to correct the wrong code for Me 

/*Question 26 (1 Points) 
Write a query using EXISTS to find all researchers who supervise at least one other researcher. 
*/

select id
from Researcher r1
where exists (
    select 1
    from Supervises s
    where r1.Id = s.SupervisorId
);

/*Question 27 (1 Points) 
Use a subquery to display each project along with the total number of researchers working on it. 
*/

select p.Title ,t.researchersTotalNumber
from ResearchProject p
join (
	select w.ProjectId [ProjectId] ,COUNT(W.ResearcherId) [researchersTotalNumber]
	from WorksOn w
	group by w.ProjectId
)as t
on t.ProjectId = p.Id

/*Question 28 (1 Points)
Write a query to find the second highest budget among all research projects (Do not use OFFSET-FETCH or ranking functions). 
*/
select MIN(Budget)  SecondHighestBudget
from (
    select TOP 2 Budget
    from ResearchProject
    order by  Budget desc
) t;

/*Question 29 (1 Points) 
Combine the list of all researcher emails and all grant funding agency names into a single list 
labeled "Contact Information". */

select Email as [Contact Information]
from Researcher
UNIon
select g.GrantName as [Contact Information]
from Grants g;


/*Question 30 (1 Points) 
Identify researchers involved in projects who have not authored any publications. 
*/
select DISTINCT r.Id, r.FirstName
from Researcher r
join WorksOn w 
    on r.Id = w.ResearcherId
where r.Id not in (
    select ResearcherId
    from Publishes
);
/*Question 31 (1 Points) 
Find researchers who supervise others and also lead one or more research projects. */
select DISTINCT r.Id, r.FirstName
from Researcher r
join Supervises s on r.Id = s.SupervisorId
join ResearchProject p on r.Id = p.LeaderId;

/*Question 32 (2 Points) 
Write a CTE to calculate the total hours per week for each researcher across all their projects, 
then use it to find researchers working more than 40 hours per week. 
*/
WITH TotalHours as (
    select w.ResearcherId,SUM(w.HoursPerWeek) as TotalHoursPerWeek
    from WorksOn w
    group by w.ResearcherId
)
select r.Id, r.FirstName, t.TotalHoursPerWeek
from TotalHours t
join Researcher r on r.Id = t.ResearcherId
where t.TotalHoursPerWeek > 40;

/*Question 33 (1 Points) 
Write a query using multiple CTEs: one to get the total budget per researcher (who leads 
projects), another to get their publication count, then join them to show researchers with 
budget > 100000 AND at least 3 publications. 
*/
WITH BudgetCTE as (
    select  p.LeaderId as ResearcherId,SUM(p.Budget) as TotalBudget
    from ResearchProject p
    group by p.LeaderId
),

PublicationCTE as (
    select  pb.ResearcherId,COUNT(pb.PublicationId) as PublicationCount
    from Publishes pb
    group by pb.ResearcherId
)

select  r.Id, r.FirstName, b.TotalBudget, pc.PublicationCount
from BudgetCTE b
join PublicationCTE pc on b.ResearcherId = pc.ResearcherId
join Researcher r on r.Id = b.ResearcherId
where  b.TotalBudget > 100000 AND pc.PublicationCount >= 3;

/*Question 34 (2 Points) 
Write a reusable function that takes a ProjectId and returns how many days the project has 
been active, calculating from the start date to either the end date or today if the project is ongoing. 
*/
Go
create or alter FUNCTIon dbo.GetProjectActiveDays (@ProjectId varchar(50))
RETURNS INT
as
BEGIN
	declare @Days INT;

    select @Days = DATEDifF( DAY,p.StartDate ,ISNULL(p.EndDate, GETDATE()))
    from ResearchProject p
    where Id = @ProjectId;

    RETURN @Days;
END;
Go
select dbo.GetProjectActiveDays(p.Id) as ActiveDays , p.Title
from ResearchProject p

/*Question 35 (2 Points) 
Write a reusable function that takes a ResearcherId and returns all projects they are involved in, 
showing the project title, their role, and hours worked per week. 
*/
Go
create or alter FUNCTIon dbo.GetResearcherProjects (@ResearcherId varchar(50))
RETURNS TABLE
as
RETURN
(
    select p.Title as ProjectTitle, w.Role, w.HoursPerWeek
    from WorksOn w
    join ResearchProject p on w.ProjectId = p.Id
    where w.ResearcherId = @ResearcherId
);
Go
select *
from dbo.GetResearcherProjects('R001');

/*Question 36 (2 Points) 
Write a function that takes a ResearcherId and returns a table containing the total number of 
projects, total publications, total hours worked per week, and average citations per publication 
for that researcher. Also, explain the scenarios where a multi-statement table-valued function is 
preferred over an inline table-valued function.
*/

Go
create FUNCTIon dbo.GetResearcherSummary (@ResearcherId varchar(50))
RETURNS @Summary TABLE(  TotalProjects INT,TotalPublications INT,TotalHoursPerWeek INT,AvgCitations FLOAT)
as
BEGIN
    declare @TotalProjects INT;declare @TotalPublications INT; declare @TotalHours INT; declare @AvgCitations FLOAT;
	-- Total Projects
    select @TotalProjects = COUNT(DISTINCT w.ProjectId)
    from WorksOn w
    where w.ResearcherId = @ResearcherId;
	-- Total Publications
    select @TotalPublications = COUNT(p.PublicationId)
    from Publishes p
    where p.ResearcherId = @ResearcherId;
	-- Total Hours
    select @TotalHours = SUM(w.HoursPerWeek)
    from WorksOn w
    where w.ResearcherId = @ResearcherId;
    -- Avg Citations
    select @AvgCitations = AVG(CasT(pp.CitationCount as FLOAT))
    from Publishes p
	join Publication pp on p.PublicationId = pp.Id
    where p.ResearcherId = @ResearcherId;


    insert into @Summary (TotalProjects, TotalPublications, TotalHoursPerWeek, AvgCitations)
    values (@TotalProjects, @TotalPublications, @TotalHours, @AvgCitations);

    RETURN;
END;
Go
select *
from dbo.GetResearcherSummary('R001');

/*Question 37 (2 Points) 
Create a non-clustered index on the ResearchProject table to improve queries that search by 
Status and StartDate.  
*/
create NonCLUSTERED INDEX IX_ResearchProject_Status_StartDate
on ResearchProject (Status, StartDate);

/*Question 38 (2 Points) 
Explain the difference between a clustered and non-clustered index. How many clustered 
indexes can a table have? What happens to existing indexes when you create a clustered index? 
*/
-- Clustered  : Physical order
-- Non-Clustered : Pointer point to record

--  How many clustered indexes can a table have?
-- Clustered     : only one per Table
-- Non-Clustered : More one Than Table

-- What happens to existing indexes when you create a clustered index?
-- the Rows Reorderd based on the Clustered index

/*Question 39 (2 Points) 
You have a query that frequently searches for researchers by Email and retrieves their 
FirstName and LastName. Write a covering index that would make this query more efficient. 
Explain what a covering index is and why it improves performance. */

-- Covering index : Conatians all require Columns in query like this index Exactly:
create NonCLUSTERED INDEX IX_Researcher_Email_Covering
on Researcher (Email)
INCLUDE (FirstName, LastName);


/*Question 40 (2 Points) 
Create a view named ActiveProjectSummary that shows project title, leader name, number of team 
members, total hours per week allocated, and total budget.. */
Go
create or alter view V_ActiveProjectSummary 
As
	select p.Title as ProjectTitle,r.FirstName as LeaderName,COUNT(w.ResearcherId) as TeamMembers,
    SUM(w.HoursPerWeek) as TotalHoursPerWeek,
    SUM(p.Budget) as TotalBudget
	from ResearchProject p 
	join Researcher r on p.LeaderId = r.Id
	LEFT join WorksOn w on p.Id = w.ProjectId
	group by p.Id, p.Title, r.FirstName;
Go
/*Question 41 (2 Points) 
Create an indexed view named ResearcherPublicationStats that shows ResearcherId, researcher full 
name, and total number of publications. Include the necessary. 
*/

create or alter VIEW dbo.ResearcherPublicationStats
WITH SCHEMABINDING
as
select 
    r.Id as ResearcherId,r.FirstName, r.LastName, COUNT_BIG(*) as TotalPublications
from dbo.Researcher r
inner join dbo.Publishes p on r.Id = p.ResearcherId
group by r.Id, r.FirstName, r.LastName;
GO
create UNIQUE CLUSTERED INDEX IX_ResearcherPublicationStats
on dbo.ResearcherPublicationStats (ResearcherId);

/*Question 42 (2 Points) 
Explain the requirements and restrictions for creating an indexed view. What are the 
performance benefits? When would you choose an indexed view over a regular view or a table? 
*/
-- if you create a Unique Clustered Index on it, the result gets physically stored on disk.
--So : he view becomes like a real table, updating automatically when data changes.

-- Huge Performance Boost  ( Pre-calculates complex Aggregations )


/*Question 43 (2 Points) 
Create a stored procedure named AddResearcherToProject that accepts ResearcherId, ProjectId, 
JoinDate, Role, and HoursPerWeek as parameters. The procedure should: 
● Validate that both researcher and project exist 
● Check that the researcher isn't already on the project 
● Insert the record into WorksOn 
● Return 0 for success, -1 for errors */
GO
create or alter PROCEDURE sp_AddResearcherToProject
    @ResearcherId VARCHAR(50), @ProjectId VARCHAR(50), @JoinDate DATE, @Role VARCHAR(100), @HoursPerWeek INT
as
BEGIN
    set nocount on;

    if not exists ( select 1 from Researcher where Id = @ResearcherId)
        RETURN -1;

    if not exists ( select 1 from ResearchProject  where Id = @ProjectId )
        RETURN -1;

    if EXISTS ( select 1 from WorksOn  where ResearcherId = @ResearcherId AND ProjectId = @ProjectId)
        RETURN -1;

    insert into WorksOn (ResearcherId, ProjectId,JoinDate,Role, HoursPerWeek)
    values(@ResearcherId, @ProjectId, @JoinDate, @Role, @HoursPerWeek);

    RETURN 0;
END
GO


/*Question 44 (2 Points) 
Create a stored procedure named UpdateProjectStatus that accepts a ProjectId and changes its 
status from 'Pending' to 'Active', but only if the project has at least one researcher assigned and 
at least one funding source. Use appropriate error handling. */
GO
create OR ALTER PROCEDURE sp_UpdateProjectStatus @ProjectId VARCHAR(50)
as
BEGIN
    SET NOCOUNT on;
    BEGIN TRY

        if not exists (select 1 from ResearchProject where Id = @ProjectId)
            RAISERROR('Project does not exist.', 16, 1);

        if not exists ( select 1 from ResearchProject where Id = @ProjectId AND Status = 'Pending')
            RAISERROR('Project is not in Pending status.', 16, 1);

        if not exists ( select 1 from WorksOn where ProjectId = @ProjectId)
            RAISERROR('Project has no researchers assigned.', 16, 1);
         
        if not exists (select 1 from Funds where ProjectId = @ProjectId)
            RAISERROR('Project has no funding sources.', 16, 1);

        UPDATE ResearchProject
        SET Status = 'Active'
        where Id = @ProjectId;

    end try
    BEGIN CATCH
        declare @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        declare @ErrorSeverity INT = ERROR_SEVERITY();
        declare @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

/*Question 45 (2 Points) 
Write a stored procedure with OUTPUT parameters that accepts a ResearcherId and returns the 
total number of projects they work on, their total publications, and their total weekly hours 
across all projects.
*/
go
create or alter procedure sp_getresearcherstats
    @researcherid varchar(50),@totalprojects int output, @totalpublications int output, @totalhours  int output
as
begin
    set nocount on;

    select @totalprojects = count(*)
    from workson
    where researcherid = @researcherid;

    select @totalpublications = count(*)
    from publishes
    where researcherid = @researcherid;

    select @totalhours = isnull(sum(hoursperweek), 0)
    from workson
    where researcherid = @researcherid;

end
go

/*Question 46 (2 Points) 
Create an AFTER insert trigger on the WorksOn table that prevents a researcher from being 
assigned to more than 5 projects. If the insertion would exceed this limit, rollback the 
transaction and raise an error. 
*/

go
create or alter trigger trg_limitresearcherprojects
on workson
after insert
as
begin
    set nocount on;

    if exists (
        select 1
        from workson w
        join inserted i on w.researcherid = i.researcherid
        group by w.researcherid
        having count(*) > 5
    )
    begin
        rollback transaction;
        raiserror ('researcher cannot be assigned to more than 5 projects.', 16,1);
    end
end
go

/*Question 47 (2 Points) 
Create a trigger on the ResearchProject table that automatically updates the Status to 
'Completed' when an EndDate is set to a date in the past. Should this be an AFTER or INSTEAD 
OF trigger? Explain your choice. 
*/
-- AFTER : => because i don't want to stop updates 
-- update operation should complete first
go
create or alter trigger trg_updatestatus_on_enddate
on researchproject
after insert, update
as
begin
    set nocount on;
    update rp
    set status = 'completed'
    from researchproject rp
    join inserted i on rp.id = i.id
    where  i.enddate is not null and i.enddate < cast(getdate() as date);
end
go


/*Question 48 (2 Points) 
Create an audit trigger that logs all updates to the Grants table. Create an appropriate audit 
table to store: GrantId, OldAmount, NewAmount, ModifiedBy (SYSTEM_USER), ModifiedDate.  
*/

create table grants_audit
(
auditid int identity(1,1) primary key,
grantid varchar(50),
oldamount decimal(18,2),
newamount decimal(18,2),
modifiedby varchar(100),
modifieddate datetime
);

go
create or alter trigger trg_audit_grants_update
on grants
after update
as
begin
    set nocount on;
    insert into grants_audit( grantid,oldamount, newamount, modifiedby, modifieddate)
    select
        d.Id,
        d.amount      as oldamount,
        i.amount      as newamount,
        system_user   as modifiedby,
        getdate()     as modifieddate
    from deleted d
    join inserted i on d.Id = i.Id
    where isnull(d.amount,0) <> isnull(i.amount,0);
end
go

/*Question 49 (4 Points) 
Write a transaction that: 
1. Creates a new research project 
2. Assigns the project leader to work on it 
3. Allocates a grant to fund it
Include proper error handling with TRY-CATCH and ROLLBACK if any step fails.*/

go
begin try
    begin transaction;

    declare @projectid varchar(50) = 'p102';
    declare @projecttitle varchar(200) = 'Machine Learning Study';
    declare @leaderid varchar(50) = 'r2';
    declare @grantid varchar(50) = 'g102';
    declare @grantamount decimal(18,2) = 100000;
    declare @startdate date = getdate();

    insert into ResearchProject( Id, Title, StartDate, Status)
    values( @projectid,@projecttitle, @startdate,'Pending' );

    insert into WorksOn (ResearcherId,ProjectId,JoinDate,Role, HoursPerWeek ) 
	values( @leaderid, @projectid, @startdate, 'Project Leader',20 );
    
	insert into Grants ( Id, GrantName,Amount, StartDate, FundingAgency)
    values(@grantid,'Main Grant for ML Study', @grantamount, @startdate,'National Science Fund');

    commit transaction;
    print 'transaction completed successfully';

end try
begin catch
    if @@trancount > 0
        rollback transaction;

    declare @errormessage nvarchar(4000) = error_message();
    declare @errorseverity int = error_severity();
    declare @errorstate int = error_state();
    raiserror(@errormessage, @errorseverity, @errorstate);
end catch
go


/*Question 50 (2 Points) 
Explain the ACID properties of transactions. For each property, give an example from the 
university research database showing why it's important. 
*/
/*ACID properties :  ensure reliable transaction processing. 
atomicity => all or nothing
consistency => valid rules maintained
isolation => no transaction interference
durability => committed = permanent
*/


/*Question 50 (2 Points) 
Write the necessary GRANT statements to: 
● Give user 'ResearchManager' full permissions on all tables 
● Give user 'ResearchAssistant' select and insert permissions only on Researcher and Publication tables 
● Give user 'DataAnalyst' select permission on all views but no direct table access 
*/
grant select, insert, update, delete
on schema::dbo
to researchmanager;

grant select, insert
on researcher
to researchassistant;

grant select, insert
on publication
to researchassistant;

grant select
on schema::dbo
to dataanalyst;

deny select, insert, update, delete
on schema::dbo
to dataanalyst;

/*Question 52 (3 Points) 
Write REVOKE statements to remove insert and UPDATE permissions from user 
'ResearchAssistant' on the Researcher table. Explain the difference between GRANT, REVOKE, 
and DENY
*/
revoke insert, update
on researcher
from researchassistant;

/*Question 53 (3 Points) 
Compare these two queries for finding researchers who work on project 'P001': 
-- A
select r.*  
from Researcher r 
where r.Id IN (select ResearcherId from WorksOn where ProjectId = 'P001') 
-- B
select r.*  
from Researcher r 
where EXISTS (select 1 from WorksOn w where w.ResearcherId = r.Id AND w.ProjectId = 'P001') 
*/
-- Which query is likely to perform better and why? -- B is Faster
-- What factors influence the optimizer's choice?  -- number of rows -- indexes --subquery --IN,EXISTS ( EXISTS is better than in)


/*Question 54 (3 Points) 
A query retrieving all projects with their researchers is running slowly: 
Suggest at least 3 different optimizations (indexes, query rewrite, etc.) that could improve 
performance.
*/
select p.Title, r.FirstName, r.LastName 
from ResearchProject p
LEFT join WorksOn w  on p.Id = w.ProjectId 
LEFT join Researcher r  on w.ResearcherId = r.Id 
where p.Status = 'Active' 
ORDER BY p.StartDate DESC 

-- index Cover this Query include(Title) help Status ,StartDate
-- index on FirstName, LastName 
-- indexed view



/*Question 55 (4 Points) 
You need to regularly retrieve the top 10 most cited publications along with their authors. You 
have four options: 
Option A: Write the query each time it's needed 
Option B: Create a view 
Option C: Create a stored procedure 
Option D: Create an indexed view 
Discuss the pros and cons of each approach. Which would you choose and why? Consider 
factors like performance, maintenance, and data freshness. 
*/
-- My choice: indexed view 
-- indexed view provides precomputed results

-- Option A: Write the query each time it's needed 
-- pros : no extra objects in database
-- cons : repetitive code - higher risk of errors - harder maintenance - no performance optimization

-- Option B: Create a view 
-- pros : reusable query - centralized logic 
-- cons : no parameter support -performance same as base query - complex joins may be slow

-- Option C: Create a stored procedure 
-- pros : better performance (execution plan cached)-supports parameters-secure 
-- cons : less flexible than raw query-needs execution call

--Option D: Create an indexed view 
-- pros : fastest read performance-great for frequent heavy queries
-- cons : slower insert / update on base tables

