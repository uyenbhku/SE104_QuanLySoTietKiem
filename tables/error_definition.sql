
/*
** KHAI BAO NHUNG MESSAGES KHI CO LOI
*/

EXECUTE sys.sp_addmessage
		@msgnum = 50001,
		@severity = 16,
		@msgtext = N'Unidentified Customer. Please add new customer before proceeding.';


EXECUTE sys.sp_addmessage
		@msgnum = 50002,
		@severity = 16,
		@msgtext = N'Invalid Deposit. Fund must be bigger than 1 million VND.';


EXECUTE sys.sp_addmessage
		@msgnum = 50003,
		@severity = 16,
		@msgtext = N'Invalid Interest Type. Please select another type.';


EXECUTE sys.sp_addmessage
		@msgnum = 50004,
		@severity = 16,
		@msgtext = N'There is an interest type with that term. Please use update.';


EXECUTE sys.sp_addmessage
		@msgnum = 50005,
		@severity = 16,
		@msgtext = N'Cannot delete after 30 minutes. Contact SA to delete.';


EXECUTE sys.sp_addmessage
		@msgnum = 50006,
		@severity = 16,
		@msgtext = N'Invalid DepositID. The system might be hacked.';
		

EXECUTE sys.sp_addmessage
		@msgnum = 50007,
		@severity = 16,
		@msgtext = N'Violate database integrity.';


EXECUTE sys.sp_addmessage
		@msgnum = 50008,
		@severity = 16,
		@msgtext = N'Invalid InterestTypeID. The system might be hacked.';


EXECUTE sys.sp_addmessage
		@msgnum = 50009,
		@severity = 16,
		@msgtext = N'Only one parameter record is allowed.';


EXECUTE sys.sp_addmessage
		@msgnum = 50010,
		@severity = 16,
		@msgtext = N'Cannot make transaction on this object anymore (Closed object).';
		

EXECUTE sys.sp_addmessage
		@msgnum = 50011,
		@severity = 16,
		@msgtext = N'Cannot update balance (Changes is NULL).';

EXECUTE sys.sp_addmessage
		@msgnum = 50012,
		@severity = 16,
		@msgtext = N'Invalid Citizen ID. This Citizen ID has been used by someone else before.';

EXECUTE sys.sp_addmessage
		@msgnum = 50013,
		@severity = 16,
		@msgtext = N'Cannot update interest rate and term (Due to dubplicate data).';

EXECUTE sys.sp_addmessage
		@msgnum = 50014,
		@severity = 16,
		@msgtext = N'Invalid Withdrawer. Withdrawer has to be null.';

EXECUTE sys.sp_addmessage
		@msgnum = 50015,
		@severity = 16,
		@msgtext = N'Asynchronous data error.';

EXECUTE sys.sp_addmessage
		@msgnum = 50016,
		@severity = 16,
		@msgtext = N'Cannot change the withdrawer"s name.';

EXECUTE sys.sp_addmessage
		@msgnum = 50017,
		@severity = 16,
		@msgtext = N'The number of days deposited must be greater than or equal to the minimum number of days to withdraw.';

EXECUTE sys.sp_addmessage
		@msgnum = 50018,
		@severity = 16,
		@msgtext = N'Invalid DepositID. DepositID has to be not null.';

EXECUTE sys.sp_addmessage
		@msgnum = 50019,
		@severity = 16,
		@msgtext = N'Can not delete this transaction.';

-- Set date format to day/month/year
SET DATEFORMAT dmy