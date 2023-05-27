### TABLE INTERESTTYPE

dbo.addInterestType : thêm loại tiết kiệm
@Params: 
	InterestRate DECIMAL(3,2)
	Term INT	
	MinimumTimeToWithdrawal INT (Optional, default = 0)

@Returns:
	0: thêm thành công
	1: thêm không thành công vì có loại tiết kiệm trùng kỳ hạn


dbo.updateInterestType : cập nhật loại tiết kiệm
@Params:
	@InterestTypeID CHAR(10) : Mã loại tiết kiệm
	@NewInterestRate DECIMAL(3,2) : Lãi suất mới (Optional)
	@NewMinimumTimeToWithdrawal INT : Thời gian rút tối thiểu mới
@Returns:
	0: cập nhật thành công
	1: cập nhật không thành công vì không có loại tiết kiệm tương ứng trong CSDL