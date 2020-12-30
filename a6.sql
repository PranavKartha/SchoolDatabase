--**********************************************************************************************--
-- Title: Assigment06 
-- Author: PKartha
-- Desc: This file demonstrates how to design and create; 
--       tables, constraints, views, stored procedures, and permissions
-- Change Log: When,Who,What
-- 2020-05-11,PKartha,Created Database
--***********************************************************************************************--



Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_PKartha')
	 Begin 
	  Alter Database [Assignment06DB_PKartha] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_PKartha;
	 End
	Create Database Assignment06DB_PKartha;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_PKartha;


-- Create Tables and Constraints (Module 01 and 02)-- 

Create table Students(
	StudentID int IDENTITY(1,1) Constraint StudentIDNotNull not null,
	StudentNumber nvarchar(100) Constraint StudentNumberUniqueNotNull Unique not null,
	StudentFirstName nvarchar(100) Constraint StudentFirstNameNotNull not null,
	StudentLastName nvarchar(100) Constraint StudentLastNameNotNull not null,
	StudentEmail nvarchar(100) Constraint StudentEmailUniqueNotNull Unique not null,
	StudentPhone nvarchar(100) Constraint PhoneNumberPattern   check (StudentPhone like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') ,
	StudentAddress1 nvarchar(100) Constraint StudentAddress1NotNull not null,
	StudentAddress2 nvarchar(100),
	StudentCity nvarchar(100) Constraint StudentCityNotNull not null,
	StudentStateCode nvarchar(100) Constraint StudentStateCodeNotNull not null,
	StudentZipCode nvarchar(100) Constraint StudentZipCodeNotNullPattern not null check(StudentZipCode like '[0-9][0-9][0-9][0-9][0-9]'  
																					or StudentZipCode like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
);

go

Alter table Students
	Add constraint pkStudents Primary Key(StudentID);
go


Create table Courses(
	CourseID int IDENTITY(1,1) Constraint CourseIDPKNotNull not null,
	CourseName nvarchar(100) Constraint CourseNameUniqueNotNull Unique not null, --Assuming all course names are unique
	CourseStartDate date,
	CourseEndDate date,
	CourseStartTime time,
	CourseEndTime time,
	CourseWeekdays nvarchar(100),
	CourseCurrentPrice money,
	Constraint endDateGreaterThanStart check (CourseEndDate > CourseStartDate),
	Constraint endTimeGreaterThanStart check (CourseEndTime > CourseStartTime)
);

go

Alter table Courses
	Add constraint pkCourses Primary Key(CourseID);
go



Create table Enrollments(
	EnrollmentID int IDENTITY(1,1) Constraint EnrollmentIDNotNull not null,
	StudentID int Constraint StudentIDNotNull not null,
	CourseID int Constraint CourseIDNotNull  not null,
	EnrollmentDateTime datetime Constraint EnrollmentDateTimeNotNullDefaultToday default getDate() not null, --																										  ,
	EnrollmentPrice money Constraint EnrollmentPriceNotNull not null

	
);

go



Create function smallerDate(@CourseID int, @EnrollmentDate  date)
	RETURNS int
	AS
	BEGIN
		--csd is the start date of the course from the Courses table
		Declare @csd as date
		Select @csd = (select CourseStartDate from Courses where CourseID = @CourseID)
			if (@EnrollmentDate > @csd) return 0 else return 1
		return 1
	END;

go

Alter table Enrollments add constraint enrollment_date_before_course_start check (dbo.smallerDate(CourseID, EnrollmentDateTime) = 1)

go





Alter table Enrollments
	Add constraint pkEnrollments Primary Key(EnrollmentID);
go


Alter table Enrollments
	Add constraint fkEnrollmentsToStudents Foreign Key(StudentID) References Students(StudentID); 
go

Alter table Enrollments
	Add constraint fkEnrollmentsToCourses Foreign Key(CourseID) References Courses(CourseID); 
go





-- Add Views (Module 03 and 04) -- 
Create view vStudents AS
	Select * from Students;
go

Create view vCourses AS
	Select * from Courses;
go

Create view vEnrollments AS
	Select * from Enrollments;
go

Create view vAll AS
	Select EnrollmentID, e.StudentID, e.CourseID, EnrollmentDateTime, EnrollmentPrice,
	StudentNumber, StudentFirstName, StudentLastName, StudentEmail, StudentPhone, StudentAddress1,StudentAddress2, 
	StudentCity, StudentStateCode, StudentZipCode, CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseWeekdays, CourseCurrentPrice
	from Enrollments as e
		join Students as s 
		on e.StudentID = s.StudentID
		join Courses as c
		on e.CourseID = c.CourseID;
go




-- Add Stored Procedures (Module 04 and 05) --

Create Procedure pInsStudents
(@StudentNumber nvarchar(100),
 @StudentFirstName nvarchar(100),
 @StudentLastName nvarchar(100),
 @StudentEmail nvarchar(100),
 @StudentPhone nvarchar(100),
 @StudentAddress1 nvarchar(100),
 @StudentAddress2 nvarchar(100),
 @StudentCity nvarchar(100),
 @StudentStateCode nvarchar(100),
 @StudentZipCode nvarchar(100)
 )
/* Author: PKartha
** Desc: Inserts values into Students Table
** Change Log: 5/8/2020-Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		Insert into Students(StudentNumber, StudentFirstName, StudentLastName,StudentEmail, StudentPhone, StudentAddress1, StudentAddress2, StudentCity,
		StudentStateCode, StudentZipCode)
			Values(@StudentNumber, @StudentFirstName, @StudentLastName,@StudentEmail, @StudentPhone, @StudentAddress1, @StudentAddress2, @StudentCity,
			@StudentStateCode, @StudentZipCode);
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go


Create Procedure pUpdStudents
(@StudentID int,
 @StudentNumber nvarchar(100),
 @StudentFirstName nvarchar(100),
 @StudentLastName nvarchar(100),
 @StudentEmail nvarchar(100),
 @StudentPhone nvarchar(100),
 @StudentAddress1 nvarchar(100),
 @StudentAddress2 nvarchar(100),
 @StudentCity nvarchar(100),
 @StudentStateCode nvarchar(100),
 @StudentZipCode nvarchar(100)
 )
/* Author: PKartha
** Desc: Updates Students table
** Change Log: 5/8/2020-Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		Update Students
			set
				StudentNumber = @StudentNumber,
				StudentFirstName = @StudentFirstName,
				StudentLastName = @StudentLastName,
				StudentEmail = @StudentEmail,
				StudentPhone = @StudentPhone,
				StudentAddress1 = @StudentAddress1,
				StudentAddress2 = @StudentAddress2,
				StudentCity = @StudentCity,
				StudentStateCode = @StudentStateCode,
				StudentZipCode = @StudentZipCode
			where StudentID = @StudentID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go


Create Procedure pDelStudents
(@StudentID int)
/* Author: PKartha
** Desc: Deletes information from Students table
** Change Log: 5/8/2020-Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		Delete from Students
			where StudentID = @StudentID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pInsCourses
(@CourseName nvarchar(100),
 @CourseStartDate date,
 @CourseEndDate date,
 @CourseStartTime time,
 @CourseEndTime time,
 @CourseWeekdays nvarchar(100),
 @CourseCurrentPrice money
 )
/* Author: PKartha
** Desc: Inserts values into Courses Table
** Change Log: 5/8/2020-Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		Insert into Courses(CourseName, CourseStartDate, CourseEndDate, CourseStartTime,
		CourseEndTime, CourseWeekdays, CourseCurrentPrice)
			Values(@CourseName, @CourseStartDate, @CourseEndDate, @CourseStartTime, @CourseEndTime, @CourseWeekdays, @CourseCurrentPrice);
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdCourses
(@CourseID int,
 @CourseName nvarchar(100),
 @CourseStartDate date,
 @CourseEndDate date,
 @CourseStartTime time,
 @CourseEndTime time,
 @CourseWeekdays nvarchar(100),
 @CourseCurrentPrice money
 )
/* Author: PKartha
** Desc: Updates Courses table
** Change Log: 5/8/2020-Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		Update Courses
			set
				CourseName = @CourseName,
				CourseStartDate = @CourseStartDate,
				CourseEndDate = @CourseEndDate, 
				CourseStartTime = @CourseStartTime,
				CourseEndTime = @CourseEndTime,
				CourseWeekdays = @CourseWeekdays,
				CourseCurrentPrice = @CourseCurrentPrice
			where CourseID = @CourseID
		Commit transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go


Create Procedure pDelCourses
(@CourseID int)
/* Author: PKartha
** Desc: Deletes information from Courses table
** Change Log: 5/8/2020-Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		Delete from Courses
			where CourseID = @CourseID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go


Create Procedure pInsEnrollments
(@StudentID int,
 @CourseID int,
 @EnrollmentDateTime date,
 @EnrollmentPrice money
 )
 
/* Author: PKartha
** Desc: Inserts values into Enrollments Table
** Change Log: 5/8/2020-Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		Insert into Enrollments(StudentID, CourseID, EnrollmentDateTime, EnrollmentPrice)
			Values(@StudentID, @CourseID, @EnrollmentDateTime, @EnrollmentPrice);
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdEnrollments
(@EnrollmentID int,
 @StudentID int,
 @CourseID int,
 @EnrollmentDateTime date,
 @EnrollmentPrice money
 )
/* Author: PKartha
** Desc: Updates Enrollments table
** Change Log: 5/8/2020-Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		Update Enrollments
			set
				StudentID = @StudentID,
				CourseID = @CourseID,
				EnrollmentDateTime = @EnrollmentDateTime,
				EnrollmentPrice = @EnrollmentPrice
			where EnrollmentID = @EnrollmentID
		Commit transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelEnrollments
(@EnrollmentID int)
/* Author: PKartha
** Desc: Deletes information from Students table
** Change Log: 5/8/2020-Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		Delete from Enrollments
			where EnrollmentID = @EnrollmentID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go



-- Set Permissions (Module 06) --
Deny Select, Insert, Update, Delete On Students To public;
Deny Select, Insert, Update, Delete On Courses To public; 
Deny Select, Insert, Update, Delete On Enrollments To public;
Grant select on vStudents to public;
Grant select on vCourses to public;
Grant select on vEnrollments to public;
Grant exec on pInsStudents to public;
Grant exec on pUpdStudents to public;
Grant exec on pDelStudents to public;
Grant exec on pInsCourses to public;
Grant exec on pUpdCourses to public;
Grant exec on pDelCourses to public;
Grant exec on pInsEnrollments to public;
Grant exec on pUpdEnrollments to public;
Grant exec on pDelEnrollments to public;


Select * from vAll

--< Test Views and Sprocs >-- 
--positive test for pInsStudents

Declare @Status int;
Exec @Status = pInsStudents @StudentNumber = '1', @StudentFirstName = 'Pranav', @StudentLastName = 'Kartha',
							@StudentEmail  = 'pkartha@gmail.com', @StudentPhone = '111-111-1111', 
							@StudentAddress1 = '23866 Se Somewhere St', @StudentAddress2 = 'address2', 
							@StudentCity = 'Seattle', @StudentStateCode = 'WA', @StudentZipCode = '92746'
Select Case @Status
	When +1 Then 'Insert Students was successful!'
	When -1 Then 'Insert Students failed! Common issues: Duplicate Data'
	End as [Status]
Select [The new identity was:] = @@IDENTITY
go

select * from Students;

--negative test for pInsStudents. Duplicate data.
Declare @Status int;
Exec @Status = pInsStudents @StudentNumber = '1', @StudentFirstName = 'Pranav', @StudentLastName = 'Kartha',
							@StudentEmail  = 'pkartha@gmail.com', @StudentPhone = '111-111-1111', 
							@StudentAddress1 = '23866 Se Somewhere St', @StudentAddress2 = 'address2', 
							@StudentCity = 'Seattle', @StudentStateCode = 'WA', @StudentZipCode = '92746'
Select Case @Status
	When +1 Then 'Insert Students was successful!'
	When -1 Then 'Insert Students failed! Common issues: Duplicate Data'
	End as [Status]
Select [The new identity was:] = @@IDENTITY
go

select * from Students;

--postive test for pUpdStudents
Declare @Status int;
Exec @Status = pUpdStudents @StudentID = 1, @StudentNumber = '1', @StudentFirstName = 'Jim', @StudentLastName = 'Kartha',
							@StudentEmail  = 'pkartha@gmail.com', @StudentPhone = '111-111-1111', 
							@StudentAddress1 = '23866 Se Somewhere St', @StudentAddress2 = 'address2', 
							@StudentCity = 'Seattle', @StudentStateCode = 'WA', @StudentZipCode = '92746'
Select Case @Status
	When +1 Then 'Update Students was successful!'
	When -1 Then 'Update Students failed! Common issues: Check values'
	End as [Status]
go

Select * from Students;


-- positive test for pDelStudents
Declare @Status int;
Exec @Status = pDelStudents @StudentID =1
Select Case @Status
	When +1 Then 'Delete Students was successful!'
	When -1 Then 'Delete Students failed! Common issues: Foreign Key Values must be deleted first'
	End as [Status]
go

Select * from Students;


--positive test for pInsStudents
Declare @Status int;
Exec @Status = pInsStudents @StudentNumber = 1, @StudentFirstName = 'Pranav', @StudentLastName = 'Kartha',
							@StudentEmail  = 'pkartha@gmail.com', @StudentPhone = '111-111-1111', 
							@StudentAddress1 = '23866 Se Somewhere St', @StudentAddress2 = 'address2', 
							@StudentCity = 'Seattle', @StudentStateCode = 'WA', @StudentZipCode = '92746'
Select Case @Status
	When +1 Then 'Insert Students was successful!'
	When -1 Then 'Insert Stdents failed! Common issues: Duplicate Data'
	End as [Status]
Select [The new identity was:] = @@IDENTITY
go

Select * from Students;

--positive test for pInsCourses
Declare @Status int;
Exec @Status = pInsCourses @CourseName = 'Science', @CourseStartDate = '2018/01/01', @CourseEndDate = '2018/02/02',
							@CourseStartTime = '01:01:20', @CourseEndTime = '01:02:40', @CourseWeekdays='Th', 
							@CourseCurrentPrice = 2
 
							
Select Case @Status
	When +1 Then 'Insert Courses was successful!'
	When -1 Then 'Insert Courses failed! Common issues: Duplicate Data'
	End as [Status]
Select [The new identity was:] = @@IDENTITY
go

Select * from vCourses;
go
--negative test for pInsCourses. Duplicate data.
Declare @Status int;
Exec @Status = pInsCourses @CourseName = 'Science', @CourseStartDate = '2018/01/01', @CourseEndDate = '2018/02/02',
							@CourseStartTime = '01:01:20', @CourseEndTime = '01:02:40', @CourseWeekdays='Th', 
							@CourseCurrentPrice = 2
 
							
Select Case @Status
	When +1 Then 'Insert Courses was successful!'
	When -1 Then 'Insert Courses failed! Common issues: Duplicate Data'
	End as [Status]
Select [The new identity was:] = @@IDENTITY
go

Select * from vCourses;
go


--postive test for pUpdCourses
Declare @Status int;
Exec @Status = pUpdCourses  @CourseID =1, @CourseName = 'Math', @CourseStartDate = '2018/01/01', @CourseEndDate = '2018/02/02',
							@CourseStartTime = '01:01:20', @CourseEndTime = '01:02:40', @CourseWeekdays='Th', 
							@CourseCurrentPrice = '2'
Select Case @Status
	When +1 Then 'Update Courses was successful!'
	When -1 Then 'Update Courses failed! Common issues: Check values'
	End as [Status]
go

Select * from vCourses;
go

--postive test for pDelCourses
Declare @Status int;
Exec @Status = pDelCourses  @CourseID =1
Select Case @Status
	When +1 Then 'Delete Courses was successful!'
	When -1 Then 'Delete Courses failed! Common issues: Foreign Key values must be deleted first'
	End as [Status]
go

Select * from vCourses;
go

--positive test for pInsCourses
Declare @Status int;
Exec @Status = pInsCourses @CourseName = 'Science', @CourseStartDate = '2018/01/01', @CourseEndDate = '2018/02/02',
							@CourseStartTime = '01:01:20', @CourseEndTime = '01:02:40', @CourseWeekdays='Th', 
							@CourseCurrentPrice = 2
 
							
Select Case @Status
	When +1 Then 'Insert Courses was successful!'
	When -1 Then 'Insert Courses failed! Common issues: Duplicate Data'
	End as [Status]
Select [The new identity was:] = @@IDENTITY
go

Select * from vCourses;
go

--positive test for pInsEnrollments
Declare @Status int;
Exec @Status = pInsEnrollments @StudentID = 3, @CourseID = 3, @EnrollmentDateTime = '2017/1/1',
							@EnrollmentPrice = 2
 
							
Select Case @Status
	When +1 Then 'Insert Enrollments was successful!'
	When -1 Then 'Insert Enrollment failed! Common issues: Duplicate Data'
	End as [Status]
Select [The new identity was:] = @@IDENTITY
go

Select * from Enrollments

--test for pUpdEnrollments
Declare @Status int;
Exec @Status = pUpdEnrollments @EnrollmentID = 1, @StudentID = 4, @CourseID = 4 , @EnrollmentDateTime = '2016/1/1',
							@EnrollmentPrice = 2
 
							
Select Case @Status
	When +1 Then 'Update Enrollement was successful!'
	When -1 Then 'Update Enrollment failed! Common issues: Duplicate Data'
	End as [Status]
Select [The new identity was:] = @@IDENTITY
go


Select * FROM Enrollments

-- test for pDelEnrollments
Declare @Status int;
Exec @Status = pDelEnrollments @EnrollmentID = 1
Select Case @Status
	When +1 Then 'Delete Enrollments was successful!'
	When -1 Then 'Delete Enrollments failed! Common issues: Foreign Key Values must be deleted first'
	End as [Status]
go

exec pDelCourses @CourseID = 3
exec pDelStudents @StudentID = 3

Select * from Enrollments;
Select * from Courses;
Select * from Students;



--inserting values from spreadsheet

exec pInsCourses @CourseName = 'SQL1 - Winter 2017', @CourseStartDate = '1/10/2017', @CourseEndDate = '1/24/2017', @CourseStartTime = '18:00:00',
				 @CourseEndTime = '20:50:00', @CourseWeekdays = 'T', @CourseCurrentPrice = 399

exec pInsCourses @CourseName = 'SQL2 - Winter 2017', @CourseStartDate = '1/31/2017', @CourseEndDate = '2/14/2017', @CourseStartTime = '18:00:00',
				 @CourseEndTime = '20:50:00', @CourseWeekdays = 'T', @CourseCurrentPrice = 399

Select * from vCourses;

exec pInsStudents @StudentNumber = 'B-Smith-071', @StudentFirstName = 'Bob', @StudentLastName = 'Smith', @StudentEmail = 'Bsmith@HipMail.com', @StudentPhone ='206-111-2222',
				  @StudentAddress1 = '123 Main St',@StudentAddress2 = '', @StudentCity ='Seattle', @StudentStateCode = 'WA', @StudentZipCode = '98801'

exec pInsStudents @StudentNumber = 'S-Jones-003', @StudentFirstName = 'Sue', @StudentLastName = 'Jones', @StudentEmail = 'SueJones@YaYou.com', @StudentPhone ='206-231-4321',
				  @StudentAddress1 = '333 1st Ave',@StudentAddress2 = '', @StudentCity ='Seattle', @StudentStateCode = 'WA', @StudentZipCode = '98801'


Select * from vStudents;


exec pInsEnrollments @StudentID = 4, @CourseID = 4, @EnrollmentDateTime = '1/3/2017', @EnrollmentPrice = 399
exec pInsEnrollments @StudentID = 4, @CourseID = 5, @EnrollmentDateTime = '1/12/2017', @EnrollmentPrice = 399
exec pInsEnrollments @StudentID = 5, @CourseID = 4, @EnrollmentDateTime = '12/14/2016', @EnrollmentPrice = 349

--statement below should  display an error message, checking if check constraint for EnrollmentDateTime before Course Start works
exec pInsEnrollments @StudentID = 5, @CourseID = 5, @EnrollmentDateTime = '2/1/2017', @EnrollmentPrice = 349  --Should fail

exec pInsEnrollments @StudentID = 5, @CourseID = 5, @EnrollmentDateTime = '1/12/2017', @EnrollmentPrice = 349  --Should succeed

Select * from vEnrollments;

--Select EnrollmentDateTime < CourseStartDate from dbo.checkStartTimes(2, '2018/02/02')
--{ IMPORTANT }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/