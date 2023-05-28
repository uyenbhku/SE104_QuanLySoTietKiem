/*
** KHAI BAO NHUNG MESSAGES KHI CO LOI
*/

EXECUTE sys.sp_addmessage
		@msgnum = 50001,
		@severity = 16,
		@msgtext = N'Unidentified Customer. Please add new customer before proceeding';


EXECUTE sys.sp_addmessage
		@msgnum = 50002,
		@severity = 16,
		@msgtext = N'Invalid Deposit. Fund must be bigger than 1 million VND';


EXECUTE sys.sp_addmessage
		@msgnum = 50003,
		@severity = 16,
		@msgtext = N'Invalid Interest Type. Please select another type';


EXECUTE sys.sp_addmessage
		@msgnum = 50004,
		@severity = 16,
		@msgtext = N'There is an interest type with that term. Please use update';


EXECUTE sys.sp_addmessage
		@msgnum = 50005,
		@severity = 16,
		@msgtext = N'Cannot delete after 30 minutes. Contact SA to delete';


EXECUTE sys.sp_addmessage
		@msgnum = 50006,
		@severity = 16,
		@msgtext = N'Invalid DepositID. The system might be hacked';

		

EXECUTE sys.sp_addmessage
		@msgnum = 50007,
		@severity = 16,
		@msgtext = N'Violate database integrity';


EXECUTE sys.sp_addmessage
		@msgnum = 50008,
		@severity = 16,
		@msgtext = N'Invalid InterestTypeID. The system might be hacked';