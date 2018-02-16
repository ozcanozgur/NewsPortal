use master
go

IF EXISTS(select * from sys.databases where name='NewsPortal')
begin
ALTER DATABASE NewsPortal SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
drop database NewsPortal;
end
go

IF NOT EXISTS(select * from sys.databases where name='NewsPortal')
create database NewsPortal
go

use NewsPortal
go

IF NOT EXISTS(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME='Portal')
BEGIN
EXEC sp_executesql N'CREATE SCHEMA Portal'
END
go

-------------------------------
Drop Table IF EXISTS Portal.ManageAdvertisement
go
Drop Table IF EXISTS Portal.ManageAuthor
go
Drop Table IF EXISTS Portal.ManageUser
go
Drop Table IF EXISTS Portal.ManageComment
go
Drop Table IF EXISTS Portal.Admins
go
Drop Table IF EXISTS Portal.Advertisement
go
Drop Table IF EXISTS Portal.GuestReadedNews;
go
Drop TABLE IF EXISTS Portal.ReadedNews;
go
Drop Table IF EXISTS Portal.Comments;
go
Drop TABLE IF EXISTS Portal.News;
go
Drop Table IF EXISTS Portal.Suggestions;
go
Drop Table IF EXISTS Portal.Popularity;
go
Drop Table IF EXISTS Portal.Authors;
go
Drop Table IF EXISTS Portal.Content;
go
DROP TABLE IF EXISTS Portal.Users; 
go
Drop TABLE IF EXISTS Portal.Guest;
go
----------PROCEDURES -----------------------------------------PROCEDURES--------------------------------

Drop Proc IF EXISTS Portal.SP_Add_News;
go
Drop Proc IF EXISTS Portal.SP_Read_News;
go
Drop Proc IF EXISTS Portal.SP_Guest_Read_News;
go
Drop Proc IF EXISTS Portal.SP_Display_News_By_Author;
go
Drop Proc IF EXISTS Portal.SP_Display_Author;
go
Drop Proc IF EXISTS Portal.SP_Add_Suggestion;
go
Drop Proc IF EXISTS Portal.SP_Add_Comments_By_User;
go
Drop Proc IF EXISTS Portal.SP_Add_Comments_By_Guest;
go
Drop Proc IF EXISTS Portal.SP_Delete_User;
go
Drop Proc IF EXISTS Portal.SP_Add_Advertisement;
go
Drop Proc IF EXISTS Portal.SP_Delete_Advertisement;
go
Drop Proc IF EXISTS Portal.SP_Display_News_By_Type;
GO
Drop proc IF EXISTS Portal.SP_Delete_Authors
go
Drop proc IF EXISTS Portal.SP_Add_Authors
go
Drop proc IF EXISTS Portal.SP_Delete_Comment
go
Drop proc IF EXISTS Portal.SP_Delete_News
go
-----------------------------------------VIEWS ---------------------------------------------VIEWS---------------------------------------
Drop View IF EXISTS Portal.DisplayNews;
go
Drop View IF EXISTS Portal.DisplayPopularNews;
go
Drop View IF EXISTS Portal.DisplayBreakingNews;
go
Drop View IF EXISTS Portal.DisplayUserComments;
go
Drop View IF EXISTS Portal.DisplayGuestComments;
go
-----------------------------------------TRIGGERS -----------------------------------------TRIGGERS------------------------------------
Drop Trigger IF EXISTS Portal.Readed_News;
go
Drop Trigger IF EXISTS Portal.Add_Comment_Trig;
go
Drop Trigger IF EXISTS Portal.Add_Suggestion_Trig;
go
------------------------------------------FUNCTIONS-------------------------------------------FUNCTIONS-----------------------------------
Drop Function IF EXISTS Portal.F_Calculate_PopRate;
GO
Drop Function IF EXISTS Portal.F_Find_Empty_Ads_Area;
GO
Drop Function IF EXISTS Portal.F_Find_Ads_Area_Of_Ads;
GO
Drop Function IF EXISTS Portal.F_Calculate_Ads_Fee;
GO

Create Table Portal.Guest 
(
	GuestID [int] IDENTITY(1,1) NOT NULL,
	GuestName [varchar](255) NULL,
	PRIMARY KEY (GuestID),
);
go

Create Table Portal.Users
(
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NULL,
	[SurName] [varchar](255) NOT NULL,
	[UserName] [varchar](255) NOT NULL unique,
	[password] [varchar](255) NOT NULL,
	[Email] [varchar](255) NULL,
	[Phone] [varchar](255) NULL
	PRIMARY KEY (UserID),
);
go

Create Table Portal.Content
(
	ContID [int] IDENTITY(1,1) NOT NULL,
	ContTitle varchar(255) NOT NULL unique,
	ContDesc Text NOT NULL,
	ContType varchar(255)NOT NULL,
	PRIMARY KEY (ContID),
);
go

Create Table Portal.Authors
(
	AuthorID [int] IDENTITY(1,1) NOT NULL,
	AuthorUserName [varchar](255) NOT NULL unique,
	AuthorPassword [varchar](255) NOT NULL,
	AuthorName [varchar](255) NOT NULL,
	AuthorSurname [varchar](255) NOT NULL,
	Author_News_Count int default 0,
	SugCount int default 0,
	PRIMARY KEY (AuthorID),
);
go

Create Table Portal.Popularity
(
	PopID [int] IDENTITY(1,1) NOT NULL,
	PopRate float default 1,
	AuthorID int,
	FOREIGN KEY (AuthorID) REFERENCES Portal.Authors(AuthorID),
	PRIMARY KEY (PopID),
);
go


Create Table Portal.Suggestions
(
	SugID [int] IDENTITY(1,1) NOT NULL,
	SugDate date default getdate(),
	SugTitle varchar(255) NOT NULL,
	SugDesc text NULL,
	AuthorPoint float not null,
	UserID int not null,
	AuthorID int not null,
	FOREIGN KEY (UserID) REFERENCES Portal.Users(UserID),
	FOREIGN KEY (AuthorID) REFERENCES Portal.Authors(AuthorID),
	PRIMARY KEY (SugID),
	check(AuthorPoint >= 0.0 and AuthorPoint <= 5.0),
);
go

Create Table Portal.News
(
	NewsID [int] IDENTITY(1,1) NOT NULL,
	NewsLocation [varchar](255) NULL,
	NewsDate date default getdate(),
	NewsPriorty int NOT NULL,
	ComCount int default 0,
	ReadCount int default 0,
	AuthorID int,
	ContID int,
	PRIMARY KEY (NewsID),
	FOREIGN KEY (AuthorID) REFERENCES Portal.Authors(AuthorID),
	FOREIGN KEY (ContID) REFERENCES Portal.Content(ContID),
	CHECK (NewsPriorty <= 3),
);
go

Create Table Portal.Comments
(
	ComID [int] IDENTITY(1,1) NOT NULL,
	ComTitle [varchar](255) NULL,
	ComDesc [varchar](255) NOT NULL,
	Com_Date date default getdate(),
	UserID int null,
	GuestID int null,
	NewsID int not null,
	FOREIGN KEY (NewsID) REFERENCES Portal.News(NewsID),
	FOREIGN KEY (UserID) REFERENCES Portal.Users(UserID),
	FOREIGN KEY (GuestID) REFERENCES Portal.Guest(GuestID),
	PRIMARY KEY (ComID),
);
go

Create Table Portal.ReadedNews
(
	ID [int] IDENTITY(1,1) NOT NULL,
	UserID int Not Null,
	NewsID int Not Null,
	Read_Time int default 0,
	PRIMARY KEY (ID),
	FOREIGN KEY (UserID) REFERENCES Portal.Users(UserID),
	FOREIGN KEY (NewsID) REFERENCES Portal.News(NewsID),
);
go

Create Table Portal.GuestReadedNews
(
	ID [int] IDENTITY(1,1) NOT NULL,
	GuestID int Not Null,
	NewsID int Not Null,
	Read_Time int default 0,
	PRIMARY KEY (ID),
	FOREIGN KEY (GuestID) REFERENCES Portal.Guest(GuestID),
	FOREIGN KEY (NewsID) REFERENCES Portal.News(NewsID),
);
go

Create Table Portal.Advertisement
(
	AdsID int IDENTITY(1,1),
	AdsArea int not null,
	EmptyAdsArea int not null default 10,
	AdsDate date not null default getdate(),
	AdsEndDate date not null default getdate(),
	AdsDuration int not null,
	AdsFee int not null,
	AdsTitle varchar(255),
	AdsDesc varchar(255),
	AdsType varchar(255),
	Primary Key(AdsID),
)
go

Create Table Portal.Admins
(
	AdminID int IDENTITY(1,1) NOT NULL,
	Name varchar(255) NULL,
	SurName varchar(55) NOT NULL,
	UserName varchar(55) NOT NULL unique,
	password varchar(55) NOT NULL,
	PRIMARY KEY (AdminID),
)
go

Create Table Portal.ManageComment
(
	ID [int] IDENTITY(1,1) NOT NULL,
	ProcessName varchar(55),
	AdminID int,
	ComID int,
	ProgressName varchar(55),
	PRIMARY KEY(ID),
	FOREIGN KEY (AdminID) REFERENCES Portal.Admins(AdminID),
	FOREIGN KEY (ComID) REFERENCES Portal.Comments(ComID),
)
go

Create Table Portal.ManageUser
(
	ID [int] IDENTITY(1,1) NOT NULL,
	AdminID int,
	UserID int,
	ProgressName varchar(55),
	PRIMARY KEY(ID),
	FOREIGN KEY (AdminID) REFERENCES Portal.Admins(AdminID),
	FOREIGN KEY (UserID) REFERENCES Portal.Users(UserID),
)
go

Create Table Portal.ManageAuthor
(
	ID [int] IDENTITY(1,1) NOT NULL,
	AdminID int,
	AuthorID int,
	ProgressName varchar(55),
	PRIMARY KEY(ID),
	FOREIGN KEY (AdminID) REFERENCES Portal.Admins(AdminID),
	FOREIGN KEY (AuthorID) REFERENCES Portal.Authors(AuthorID),
)
go

Create Table Portal.ManageAdvertisement
(
	ID [int] IDENTITY(1,1) NOT NULL,
	AdminID int,
	AdsID int,
	ProgressName varchar(55),
	ProgressDate date not null default getdate(),
	PRIMARY KEY(ID),
	FOREIGN KEY (AdminID) REFERENCES Portal.Admins(AdminID),
	FOREIGN KEY (AdsID) REFERENCES Portal.Advertisement(AdsID),
)
go


--------------------------------------------FUNCTIONS---------------------------------------FUNCTIONS------------------------------------
CREATE FUNCTION Portal.F_Calculate_PopRate
(
	@PopRate float,
	@SugCount int,
	@AuthorPoint float
)
RETURNS float 
AS
BEGIN
 
  DECLARE @Result float;
  SET @Result = ((@PopRate * @SugCount) + @AuthorPoint)/(@SugCount+1);
 
RETURN(@Result)
END
go-- Function Calculates the Popularity Rate Of Author

CREATE FUNCTION Portal.F_Find_Empty_Ads_Area()
RETURNS int 
AS
BEGIN
 
  DECLARE @Result int;
  SET @Result = (SELECT MIN(EmptyAdsArea) FROM Portal.Advertisement); 
 
RETURN(@Result)
END
go-- returns Empty Ads Area

CREATE FUNCTION Portal.F_Find_Ads_Area_Of_Ads
(
@AdsTitle varchar(55)
)
RETURNS int 
AS
BEGIN
 
  DECLARE @Result int;
  SET @Result = (SELECT AdsArea FROM Portal.Advertisement where AdsTitle = @AdsTitle); 
 
RETURN(@Result)
END
go-- return Ads Area Of Filtered Ads

CREATE FUNCTION Portal.F_Calculate_Ads_Fee
(
	@AdsArea int,
	@AdsDurationDay int
)
RETURNS int 
AS
BEGIN
 
  DECLARE @Result int;
  SET @Result = 50*@AdsArea*@AdsDurationDay;
 
RETURN(@Result)
END
go
-----------------------------------------TRIGGERS -----------------------------------------TRIGGERS------------------------------------
Create Trigger Add_News ON Portal.News 
AFTER INSERT AS 
BEGIN
DECLARE @AuthorID varchar(255);
select @AuthorID = i.AuthorID from inserted i;

update [Portal].[Authors] set Author_News_Count = Author_News_Count + 1 where AuthorID = @AuthorID;
PRINT 'COUNTER has INCREASED';
END
go -- Haber eklendiðinde Yazarýn Haber sayasýný arttýrýr

Create Trigger Add_Comment_Trig ON Portal.Comments 
After INSERT AS 
BEGIN
DECLARE @NewsID int;
select @NewsID = i.NewsID from inserted i;
update Portal.News set ComCount = ComCount + 1 where NewsID = @NewsID;
PRINT 'Readed COUNTER has INCREASED';
END
go-- Comment Eklendiðinde Ýlgili Haberin Comment Sayýsýný Arttýran Trigger

Create Trigger Add_Suggestion_Trig ON Portal.Suggestions
After INSERT AS 
BEGIN
DECLARE @AuthorID int;
select @AuthorID = i.AuthorID from inserted i;
update Portal.Authors set SugCount = SugCount + 1 where AuthorID = @AuthorID;
PRINT 'Readed COUNTER has INCREASED';
END
GO-- Suggestion Eklendiðinde Yazarýn Suggestion Sayýsýný Arttýran Trigger


-----------------------------------------VIEWS ---------------------------------------------VIEWS---------------------------------------


CREATE VIEW Portal.DisplayNews AS
SELECT N.NewsDate,N.NewsLocation,C.ContDesc,C.ContTitle,C.ContType,A.AuthorName FROM Portal.News N, Portal.Content C, Portal.Authors A  where C.ContID = N.ContID and A.AuthorID = N.AuthorID;  -- ekli olan tüm haberleri gösterir
go

CREATE VIEW Portal.DisplayPopularNews AS
SELECT top(5) N.NewsLocation, N.NewsDate, C.ContTitle, C.ContDesc, C.ContType, A.AuthorName, N.ReadCount FROM Portal.News N, Portal.Content C, Portal.Authors A  
where C.ContID = N.ContID and A.AuthorID = N.AuthorID order by ReadCount desc
go -- En çok týklanan beþ haberi gösrerir

CREATE VIEW Portal.DisplayBreakingNews AS
SELECT top(5) N.NewsLocation, N.NewsDate, C.ContTitle, C.ContDesc, C.ContType, A.AuthorName,N.NewsPriorty FROM Portal.News N, Portal.Content C, Portal.Authors A  
where C.ContID = N.ContID and A.AuthorID = N.AuthorID and N.NewsPriorty = 3 order by NewsDate desc
GO--- Displays Breaking News By Check Priorty Number 

CREATE VIEW Portal.DisplayUserComments AS
select ComTitle, ComDesc, U.UserName, CN.ContTitle from Portal.Comments C, Portal.Users U, Portal.News N, Portal.Content CN
where C.UserID is not null and C.UserID = U.UserID and C.NewsID =  N.NewsID and N.ContID = CN.ContID
go---- User kaynaklý Commentleri News Title ile birlikte gösterir

CREATE VIEW Portal.DisplayGuestComments AS
select  G.GuestName, ComTitle, ComDesc, CN.ContTitle from Portal.Comments C, Portal.Guest G, Portal.News N, Portal.Content CN
where C.GuestID is not null and C.GuestID = G.GuestID and C.NewsID =  N.NewsID and N.ContID = CN.ContID;
go--- Guest Kaynaklý Commentleri News Title ile birlikte gösterir

CREATE VIEW Portal.DisplayExpiredAds AS
select * from Portal.Advertisement
where AdsEndDate < AdsDate
go--- Süresi geçen reklamlarý görüntüler


-----------------------------------------PROCEDURES -----------------------------------------PROCEDURES--------------------------------



Create PROCEDURE Portal.SP_Add_News
(
	@NewsLocation varchar(255),
	@NewsPriorty int,
	@AuthorID int,
	@ContTitle VARCHAR(55),
	@ContDesc text,
	@ContType VARCHAR(20)
)
AS
BEGIN  
	IF (@NewsLocation IS NULL  OR @NewsPriorty IS NULL  OR @AuthorID IS NULL  OR @ContTitle IS NULL  OR
	 @ContDesc IS NULL  OR @ContType IS NULL)
	 begin
		raiserror('There is NULL values', 15, 1)end
	 Else
		 begin 
			Begin Try
				IF EXISTS(select AuthorID from portal.Authors WHERE AuthorID = @AuthorID)
				 begin
						insert into Portal.Content (ContTitle, ContDesc, ContType) values (@ContTitle, @ContDesc, @ContType);
						insert into Portal.News (NewsLocation, NewsPriorty, AuthorID, ContID)
						values (@NewsLocation, @NewsPriorty, @AuthorID, (select ContID from Portal.Content where ContTitle LIKE @ContTitle));
						Print 'Add Progress is Successfully Done';
					end
					else print 'This Author Doesn''t Exist'
			end try
			begin catch
				PRINT 'Content Title cannot Be The Same';
			end catch	
		end
END   
GO-- Add News(@NewsLocation, @NewsPriorty, @AuthorID, @ContTitle, @ContDesc, @ContType)

Create Procedure Portal.SP_Display_News_By_Type
(
	@ContType varchar(55)
)
AS
BEGIN 
	 begin try
		if exists(select * from Portal.Content  where ContType = @ContType)
		begin
			SELECT N.NewsDate,N.NewsLocation,C.ContDesc,C.ContTitle,C.ContType FROM Portal.News N , Portal.Content C   where C.ContID = N.ContID and C.ContType = @ContType;
		end
		else 
			print 'Ýnvalid Type'
	end try
	begin catch
			SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO-- Display neyws by filtering with News Type

Create PROCEDURE Portal.SP_Read_News
(
	@UserID int,
	@NewsID int
)
AS
BEGIN 
	 begin try
		if exists(select R.ID from Portal.ReadedNews R where R.UserID = @UserID and R.NewsID = @NewsID)
		begin 
			update Portal.ReadedNews set Read_Time = Read_Time + 1 where UserID = @UserID and NewsID = @NewsID;
			update Portal.News set ReadCount =  ReadCount + 1 where NewsID = @NewsID;
			SELECT N.NewsDate,N.NewsLocation,C.ContDesc,C.ContTitle,C.ContType FROM Portal.News N , Portal.Content C   where C.ContID = N.ContID and n.NewsID = @NewsID;
		end
		else
		begin
			insert Portal.ReadedNews (UserID , NewsID) values ((select U.UserID from portal.Users U where U.UserID = @UserID), 
			(select N.NewsID from Portal.News N where N.NewsID = @NewsID));
			SELECT N.NewsDate,N.NewsLocation,C.ContDesc,C.ContTitle,C.ContType FROM Portal.News N , Portal.Content C   where C.ContID = N.ContID and n.NewsID = @NewsID;
			update Portal.ReadedNews set Read_Time = Read_Time + 1 where UserID = @UserID and NewsID = @NewsID;
			update Portal.News set ReadCount = ReadCount + 1 where NewsID = @NewsID;
		end
	end try
	begin catch
		if not exists(select U.UserID from Portal.Users U where U.UserID = @UserID)
			Print 'User Information Cannot be Found.'
		else if not exists(select N.NewsID from Portal.News N where N.NewsID = @NewsID)
			Print 'News Information Cannot be Found.'
		else
			SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO-- Display News By User and get record To Readed_News @UserID, @NewsID 

Create PROCEDURE Portal.SP_Guest_Read_News(
	@GuestID int,
	@NewsID int
)
AS
BEGIN 
	 begin try
		if exists(select G.ID from Portal.GuestReadedNews G where G.GuestID = @GuestID and G.NewsID = @NewsID)
		begin 
			update Portal.GuestReadedNews set Read_Time = Read_Time + 1 where GuestID = @GuestID and NewsID = @NewsID;
			update Portal.News set ReadCount =  ReadCount + 1 where NewsID = @NewsID;
			SELECT N.NewsDate,N.NewsLocation,C.ContDesc,C.ContTitle,C.ContType FROM Portal.News N , Portal.Content C  where C.ContID = N.ContID and n.NewsID = @NewsID;
		end
		else
		begin
			insert Portal.GuestReadedNews (GuestID , NewsID) values ((select G.GuestID from portal.Guest G where G.GuestID = @GuestID), 
			(select N.NewsID from Portal.News N where N.NewsID = @NewsID));
			SELECT N.NewsDate,N.NewsLocation,C.ContDesc,C.ContTitle,C.ContType FROM Portal.News N , Portal.Content C  where C.ContID = N.ContID and n.NewsID = @NewsID;
			update Portal.GuestReadedNews set Read_Time = Read_Time + 1 where GuestID = @GuestID and NewsID = @NewsID;
			update Portal.News set ReadCount = ReadCount + 1 where NewsID = @NewsID;
		end
	end try
	begin catch
		if not exists(select U.UserID from Portal.Users U where U.UserID = @GuestID)
			Print 'Guest  Information Cannot be Found'
		else if not exists(select N.NewsID from Portal.News N where N.NewsID = @NewsID)
			Print 'Haber Information Cannot be Found'
		else
			SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO-- Display News By Guest and get record To Guest_Readed_News @GuestID, @NewsID

Create Procedure Portal.SP_Display_News_By_Author
(
	@AuthorID int
)
AS
BEGIN
	begin try
		if exists(select * from portal.Authors where AuthorID = @AuthorID)
			begin
				SELECT N.NewsDate,N.NewsLocation,C.ContDesc,C.ContTitle,C.ContType,A.AuthorName 
				FROM Portal.News N, Portal.Content C, Portal.Authors A  where C.ContID = N.ContID and A.AuthorID = N.AuthorID and A.AuthorID = @AuthorID;
			end
		else

		begin	
			PRINT 'This Author Doesn''t Exist'
		end
	end try 
	begin catch
	end catch
END
go-- Display news By Filtering with @AuthorID

Create PROCEDURE Portal.SP_Add_Suggestion
(
	@SugTitle varchar(55),
	@SugDesc Text,
	@UserID int,
	@AuthorID int,
	@AuthorPoint float
)
AS
BEGIN 
	begin try
		declare @SugCount int;
		Select @SugCount = A.SugCount from Authors A where A.AuthorID = @AuthorID;

		insert Portal.Suggestions (SugTitle,SugDesc,AuthorPoint,UserID,AuthorID) values (@SugTitle,@SugDesc, @AuthorPoint,
		(select U.UserID from Users U where U.UserID = @UserID),
		(select A.AuthorID from Authors A where A.AuthorID = @AuthorID))--suggestion ekler
		if exists(select * from Portal.Popularity P, Portal.Authors A where P.AuthorID = @AuthorID)
			begin
				update Portal.Popularity set PopRate = (select portal.F_Calculate_PopRate(PopRate,@SugCount, @AuthorPoint)) where AuthorID = @AuthorID;
			end 
		else
			begin
				insert Portal.Popularity (PopRate,AuthorID) values (@AuthorPoint,@AuthorID);
				
			end
	end try
	begin catch
		if not exists(select AuthorID from Portal.Authors  where AuthorID = @AuthorID)
			Print 'Guest Information Cannot be Found.'
		Else if not exists(select UserID from Portal.Users where UserID = @UserID)
			Print 'User Information Cannot be Found.'
		else
			SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO-- Add Suggestion and Sets Other Things @SugTitle, @SugDesc, @UserID, @AuthorID, @AuthorPoint

Create Procedure Portal.SP_Add_Comments_By_User
(
	@ComTitle varchar(55),
	@ComDesc Text,
	@UserID int,
	@NewsID int
)
AS
BEGIN 
	begin try
		insert Portal.Comments (ComTitle,ComDesc,UserID,NewsID) values (@ComTitle, @ComDesc, @UserID, @NewsID)
	end try
	begin catch
		
			SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO-- Insert User Comments @ComTitle, @ComDesc, @UserID, @NewsID

Create Procedure Portal.SP_Add_Comments_By_Guest
(
	@ComTitle varchar(55),
	@ComDesc Text,
	@GuestID int,
	@NewsID int
)
AS
BEGIN 
	begin try
		insert Portal.Comments (ComTitle,ComDesc,GuestID,NewsID) values (@ComTitle, @ComDesc, @GuestID, @NewsID)
	end try
	begin catch
		
			SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO-- Insert Guest Comments ComTitle, @ComDesc, @GuestID, @NewsID

Create PROCEDURE Portal.SP_Display_Author
(
	@AuthorName varchar(55) null
)
AS
BEGIN 
	begin try
		select AuthorName, AuthorSurname, Author_News_Count, cast(PopRate as decimal(10,2)) as authorPoint
		from Portal.Authors A, Portal.Popularity P where A.AuthorName = @AuthorName and A.AuthorID = P.AuthorID order by Author_News_Count desc;
	end try
	begin catch
		if not exists(select AuthorID from Portal.Authors  where AuthorName = @AuthorName)
			Print 'Author Information Cannot be Found.'
		else
			SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO-- Display Authors By Filtering with @AuthorName

Create PROCEDURE Portal.SP_Delete_User
(
	@UserName varchar(55),
	@AdminID int
)
AS
BEGIN 
	begin try
	if exists (select * from Portal.Admins A where A.AdminID = @AdminID )
		begin
			if exists(select * from Portal.Users U where U.UserName = @UserName)
			begin
			alter table Portal.ReadedNews nocheck constraint all;
				declare @UserID int;
				select @UserID = U.UserID from portal.Users U where U.UserName = @UserName;
				delete from portal.Suggestions  where Suggestions.UserID = @UserID;
				delete from portal.Comments  where Comments.UserID = @UserID;
				delete from portal.Users where UserName = @UserName;
			end
			else
				print 'User Information Cannot be Found.'
		end
	else
		Print 'Admin Informations Are Not Correct.'
		
	end try
	begin catch
		
			Print 'User Information Cannot be Found.'
		
			SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO-- sistemden kullanýcý siler @UserName, @AdminID

Create PROCEDURE Portal.SP_Add_Advertisement
(
	@AdsTitle varchar(55),
	@AdsType varchar(55),
	@AdsDesc varchar(55),
	@AdsArea int,
	@AdsDurationDay int,
	@AdminID int
)
AS
BEGIN 
	begin try
		if exists(select * from Portal.Admins where AdminID = @AdminID)
		begin
			if exists(select * from portal.Advertisement where AdsTitle = @AdsTitle)
				print 'The Advertisement Allready Exists'
			else
				begin
				if(Portal.F_Find_Empty_Ads_Area() < @AdsArea)
					print'There is no Enough Ads Area In the System'
				else
				begin
					insert Portal.Advertisement (AdsArea, AdsDuration, AdsFee, AdsTitle, AdsDesc, AdsType) 
					values (@AdsArea,@AdsDurationDay,Portal.F_Calculate_Ads_Fee(@AdsArea,@AdsDurationDay), @AdsTitle , @AdsDesc , @AdsType)
		
					update Portal.Advertisement set EmptyAdsArea = Portal.F_Find_Empty_Ads_Area () - @AdsArea;
					update portal.Advertisement set AdsEndDate = GETDATE() + @AdsDurationDay where AdsDuration = @AdsDurationDay and AdsTitle = @AdsTitle

					insert Portal.ManageAdvertisement (ProgressName,AdminID,AdsID) values ('Insert',(select AdminID from Portal.Admins where AdminID = @AdminID),
				(select AdsID from Portal.Advertisement where AdsTitle = @AdsTitle));
				Print 'Insert Process is Done';

				end
			end
		end
		else
			print 'Admin did not found'
	end try
	begin catch
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO--Adds Advertisement to System @AdsTitle, @AdsType, @AdsDesc, @AdsArea, @AdsFee, @AdsDurationDay, @AdminID

Create PROCEDURE Portal.SP_Delete_Advertisement
(
	@AdsTitle varchar(55),
	@AdminID int
)
AS
BEGIN 
	begin try
		if exists(select * from Portal.Admins where AdminID = @AdminID)
		begin
			if exists(select * from Portal.Advertisement where AdsTitle = @AdsTitle)
			begin
				alter table Portal.ManageAdvertisement nocheck constraint all;
				insert Portal.ManageAdvertisement (ProgressName,AdminID,AdsID) values ('Delete',(select AdminID from Portal.Admins where AdminID = @AdminID),
				(select AdsID from Portal.Advertisement where AdsTitle = @AdsTitle));
				update Portal.Advertisement set EmptyAdsArea = Portal.F_Find_Ads_Area_Of_Ads(@AdsTitle) + Portal.F_Find_Empty_Ads_Area();
				delete from Portal.Advertisement where AdsTitle = @AdsTitle;
				
				Print 'Delete Process is Done';
			end
			else
				print'There is no Advertisement With This Title'
		end
		else
			print'Admin did not found'
	end try
	begin catch
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO--Delete Advertisement From The System @AdsTitle, @AdminID

Create Procedure Portal.SP_Delete_Authors
(
	@AuthorID varchar(55),
	@AdminID int
)
AS
BEGIN 
	begin try
		if exists(select * from Portal.Admins where AdminID = @AdminID)
		begin
			if exists(select * from Portal.Authors where AuthorID = @AuthorID)
			begin
			alter table Portal.ManageAuthor nocheck constraint all;
			alter table Portal.ReadedNews nocheck constraint all;
			alter table Portal.GuestReadedNews nocheck constraint all;
				insert Portal.ManageAuthor(ProgressName,AdminID,AuthorID) values ('Delete',(select AdminID from Portal.Admins where AdminID = @AdminID),
				(select AuthorID from Portal.Authors where AuthorID = @AuthorID));
				delete from portal.Comments  where  NewsID IN (select NewsID from Portal.News  where AuthorID = @AuthorID)
				delete from Portal.News where AuthorID = @AuthorID
				delete from Portal.Suggestions where AuthorID = @AuthorID
				delete from Portal.Popularity where AuthorID = @AuthorID
				delete from portal.Authors where AuthorID = @AuthorID
				
				Print 'Delete Process is Done';
			end
			else
				print'There is no Author With This AuthorID'
		end
		else
			print'Admin did not found'
	end try
	begin catch
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO--@AuthorID, @AdminID

Create Procedure Portal.SP_Add_Authors
(
	@AdminID int,
	@AuthorUserName varchar(55),
	@AuthorPassword varchar(55), 
	@AuthorName varchar(55),
	@AuthorSurname varchar(55)
)
AS
BEGIN 
	begin try
		if exists(select * from Portal.Admins where AdminID = @AdminID)
		begin
			if not exists(select * from Portal.Authors A where A.AuthorUserName = @AuthorSurname)
			begin
				insert Portal.Authors (AuthorUserName, AuthorPassword, AuthorName, AuthorSurname)values(@AuthorUserName, @AuthorPassword, @AuthorName, @AuthorSurname)
				insert Portal.ManageAuthor(ProgressName,AdminID,AuthorID) values ('Insert',(select AdminID from Portal.Admins where AdminID = @AdminID),
				(select AuthorID from Portal.Authors where AuthorUserName = @AuthorUserName));
				Print 'Insert Process is Done';
			end
			else
				print'The Author is Exists'
		end
		else
			print'Admin did not found'
	end try
	begin catch
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO--@AdminID, @AuthorUserName, @AuthorPassword, @AuthorName,@AuthorSurname

Create Procedure Portal.SP_Delete_Comment
(
	@CommentID int,
	@AdminID int
)
AS
BEGIN 
	begin try
		if exists(select * from Portal.Admins where AdminID = @AdminID)
		begin
			if exists(select * from Portal.Comments C where C.ComID = @CommentID)
			begin
			alter table Portal.ManageComment nocheck constraint all;
			insert Portal.ManageComment(ProgressName,AdminID,ComID) values ('Delete',(select AdminID from Portal.Admins where AdminID = @AdminID),
				(select ComID from Portal.Comments where ComID = @CommentID));
				delete from portal.Comments  where  ComID = @CommentID;
				
				
				Print 'Delete Process is Done';
			end
			else
				print'There is no Comment With This ID'
		end
		else
			print'Admin did not found'
	end try
	begin catch
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  

GO--@CommentID, @AdminID
Create Procedure Portal.SP_Delete_News
(
	@NewsID varchar(55),
	@AdminID int
)
AS
BEGIN 
	begin try
		if exists(select * from Portal.Admins where AdminID = @AdminID)
		begin
			if exists(select * from Portal.News where NewsID = @NewsID)
			begin
			alter table Portal.ReadedNews nocheck constraint all;
			alter table Portal.GuestReadedNews nocheck constraint all;
				delete from portal.Comments  where  NewsID IN (select NewsID from Portal.News  where NewsID = @NewsID);
				delete from Portal.News where NewsID = @NewsID;
				Print 'Delete Process is Done';
			end
			else
				print'There is no News With This ID'
		end
		else
			print'Admin did not found'
	end try
	begin catch
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END  
GO--@NewsID, @AdminID




insert Portal.Authors (AuthorUserName, AuthorPassword, AuthorName, AuthorSurname)values('ozcanozgur', 'qwe123asd123', 'ozcan', 'ozgur')
go
insert Portal.Authors (AuthorUserName, AuthorPassword, AuthorName, AuthorSurname)values('ipekcinar', 'qwe123asd123', 'ipek', 'cinar')
go
insert Portal.Authors (AuthorUserName, AuthorPassword, AuthorName, AuthorSurname)values('mehmetdemirkol', 'qwe123asd123', 'Mehmet', 'Demirkol')
go
insert Portal.Authors (AuthorUserName, AuthorPassword, AuthorName, AuthorSurname)values('guntekinonay', 'qwe123asd123', 'Guntekin', 'Onay')
go

insert Portal.Users (Name, SurName, UserName, password, Email, Phone) values ('ozcan','ozgur','ozcanozgur','qwe123asd123','ozcanozgur123@gmail.com','5364571245');
go
insert Portal.Users (Name, SurName, UserName, password, Email, Phone) values ('ipek','cinar','ipekcinar','qwe123asd123','cinaripekk@gmail.com','539445124');
go
insert Portal.Users (Name, SurName, UserName, password, Email, Phone) values ('rýdvan','dilmen','rýdvandilmen','qwe123asd123','r.dilmen@hotmail.com','5384567542');
go
insert Portal.Users (Name, SurName, UserName, password, Email, Phone) values ('ahmet','cakar','ahmetcakar','qwe123asd123','a.cakar@hotmail.com', '5342374514');
go

insert Portal.Guest(GuestName) values ('ozcan');
go
insert Portal.Guest(GuestName) values ('ipek');
go
insert Portal.Guest(GuestName) values ('öznur');
go

insert Portal.Admins(Name,SurName,UserName,password) values ('ozcan','ozgur','ozcanozgur','qwe123asd123');
go
insert Portal.Admins(Name,SurName,UserName,password) values ('ipek','cinar','ipekcinar','qwe123asd123');
go
insert Portal.Admins(Name,SurName,UserName,password) values ('oznur','sengel','oznursengel','qwe123asd123');
go


exec Portal.SP_Add_News 'Fransa',3,1,'Fransada Þok 300 kiþiyi Taþýyan Feribot...','France Info isimli radyo kanalýnýn haberine göre, Avrupanýn göçmen krizi karþýsýndaki çaresizliðinin sembollerinden biri olan Calaisde bir feribot þiddetli rüzgâr sýrasýnda karaya oturdu.','Dünya'
go--Adds News(@NewsLocation, @NewsPriorty, @AuthorID, @ContTitle, @ContDesc, @ContType)
exec Portal.SP_Add_News 'Kayseri',3,4,'Þenol Güneþe Saldýrý Ýddiasý!','Kayserideki Maçýn Ardýndan Taraftarlar Þenol Güneþe saldýrdý','Spor'
go
exec Portal.SP_Add_News 'USA',2,2,'Çalýþmak için en iyi þirketler','Listedeki þirketler saðladýklarý imkanlarla insanlarýn yoðun ilgisini çekiyor. Ýlk sýrada ne Apple ne de Google var! Bakýn zirvede hangi þirket var? Ýþte o liste...','Ýþ Yaþam'
go
exec Portal.SP_Add_News 'atakoy',1,3,'Oyuncu Hazal Þenel kaza geçirdi','Bir zamanlarýn sevilen dizisi Selenada canlandýrdýðý Kývýlcým karakteriyle meþhur olan Hazal Þenel kaza geçirdi. Güzel oyuncu geçirdiði kazayý sosyal medya hesabýndan takipçileriyle paylaþtý.','Fiskos'
go

exec Portal.SP_Add_Suggestion 'Oneri','Haberlerinizi daha özgün bir dille yazarsanýz sevinirim',1,1,3
go--Adds Suggestion and Sets Other Things @SugTitle, @SugDesc, @UserID, @AuthorID, @AuthorPoint

exec Portal.SP_Add_Comments_By_User 'aaa','aaa',1,1
go--Adds User Comments @ComTitle, @ComDesc, @UserID, @NewsID

exec Portal.SP_Add_Comments_By_Guest 'aaa','aaa',1,1
go--Adds Guest Comments ComTitle, @ComDesc, @GuestID, @NewsID

exec Portal.SP_Add_Comments_By_User 'aaa','aaa',3,2
go--Adds User Comments @ComTitle, @ComDesc, @UserID, @NewsID

exec Portal.SP_Add_Comments_By_Guest 'aaa','aaa',2,3
go--Adds Guest Comments ComTitle, @ComDesc, @GuestID, @NewsID

exec Portal.SP_Add_Advertisement 'Turkcell', 'For A Year', 'Mountly  Thousand Minute 10$',1, 365, 1
go--Adds Advertisement to System @AdsTitle, @AdsType, @AdsDesc, @AdsArea, @AdsDurationDay, @AdminID int

exec Portal.SP_Add_Advertisement 'Vodafone', 'For A Year', 'Mountly  1GB Internet 15$',5, 365, 1
go--Adds Advertisement to System @AdsTitle, @AdsType, @AdsDesc, @AdsArea, @AdsDurationDay, @AdminID int

exec Portal.SP_Add_Authors 1,'rýdvandilmen','qwe123asd123','Rýdvan','Dilmen'
GO--@AdminID, @AuthorUserName, @AuthorPassword, @AuthorName,@AuthorSurname


/* --test display and delete procedures
exec Portal.SP_Display_News_By_Author 1
go --Display news By Filtering with @AuthorID

exec Portal.SP_Read_News 1,1
go --Display News By User and get record To Readed_News @UserID, @NewsID 

exec Portal.SP_Guest_Read_News 1,1
go --Display News By Guest and get record To Guest_Readed_News @GuestID, @NewsID

exec Portal.SP_Display_Author 'ozcan'
go --Display Authors By Filtering with @AuthorName

exec Portal.SP_Delete_Advertisement 'Turkcell',1
go --Delete Advertisement From The System @AdsTitle, @AdminID

exec Portal.SP_Delete_User 'ozcanozgur',1
go --sistemden kullanýcý siler @UserName, @AdminID

exec Portal.SP_Delete_Authors 1,1
GO --@AuthorID, @AdminID
select * from Portal.News
exec Portal.SP_Delete_News 2,1
GO --@NewsID, @AdminID

exec Portal.SP_Delete_Comment 1,1
GO --@CommentID, @AdminID
*/
----- test display and delete procedures

/*
select * from Portal.DisplayBreakingNews

select * from Portal.DisplayNews

select * from Portal.DisplayPopularNews

select * from Portal.DisplayGuestComments

select * from Portal.DisplayUserComments

select * from Portal.DisplayExpiredAds
*/
--Sistemde Bulunan Viewler



