# TABLE CUSTOMER : bảng KHACHHANG

dbo.addCustomer : thêm khách hàng mới \
@Params: 
- `CustomerName` VARCHAR(40) : Tên khách hàng 
- `PhoneNumber` VARCHAR(20)	: Số điện thoại 
- `CitizenID` VARCHAR(20) : Căn cước công dân
- `CustomerAddress` VARCHAR(100) : Địa chỉ

@Returns:
- Record set (CustomerID): chứa mã khách hàng được thêm thành công


<hr>

dbo.updateCustomer : thay đổi thông tin khách hàng \
@Params: 
- `CustomerID` INT : mã khách hàng
- `CustomerName` VARCHAR(40) : tên khách hàng (mặc định = NULL)
- `PhoneNumber`VARCHAR(20) : số điện thoại (mặc định = NULL)
- `CitizenID` VARCHAR(20) : CCCD/CMND (mặc định = NULL)
- `CustomerAddress` VARCHAR(100) : địa chỉ (mặc định = NULL) 

@Returns
- 0: cập nhật thành công
- 1: Không có sự cập nhật nào xảy ra do tất cả các tham số truyền vào đều là null hoặc không tồn tại mã khách hàng cần cập nhật trong CSDL


<hr>

dbo.getCustomerDetailWithCitizenID : lấy chi tiết khách hàng với CCCD \
@Params:
- `CitizenID` INT : Căn cước công dân

@Returns: 
- Record set (CustomerID, CustomerName, CustomerAddress, PhoneNumber): tìm kiếm thành công




# TABLE INTERESTTYPES : bảng LOAITK

dbo.addInterestType : thêm loại tiết kiệm \
@Params: 
- `InterestRate` DECIMAL(3,2) : Lãi suất mới 
- `Term` INT	: Kỳ hạn mới 
- `MinimumTimeToWithdrawal` INT (Optional, default = 0) : thời gian rút tối thiểu 

@Returns:
- 0: thêm thành công, nếu loại tiết kiệm đã có trong database nhưng bị blocked thì tự động unblocked chứ không thêm mới


<hr>

dbo.updateInterestType : cập nhật số ngày rút tối thiểu loại tiết kiệm \
@Params:
- `InterestTypeID` INT : Mã loại tiết kiệm
- `NewMinimumTimeToWithdrawal` INT (mặc định = NULL) : Thời gian rút tối thiểu mới (Optional)

@Returns:
- 0: cập nhật thành công

<hr>

dbo.blockInterestType : "khóa" loại tiết kiệm \
@Params:
- `InterestTypeID` INT : Mã loại tiết kiệm

@Returns:
- 0: cập nhật thành công


<hr>

dbo.unblockInterestType : "mở khóa" loại tiết kiệm \
@Params:
- `InterestTypeID` INT : Mã loại tiết kiệm

@Returns:
- 0: unblock thành công


<hr>

dbo.getInterestType : tra cứu loại tiết kiệm theo kỳ hạn và lãi suất \
@Params:
- `Term` INT : Kỳ hạn
- `InterestRate` DECIMAL(3,2) : Lãi suất

@Returns:
- Record set (InterestTypeID, InterestTypeName, InterestRate, Term, MinimumTimeToWithdrawal): tìm kiếm thành công



# TABLE PARAMS : bảng THAMSO

dbo.updateMinimumDeposit : Cập nhật quy định số tiền gửi tối thiểu \
@Params:
- `NewMinimumDeposit` TEXT : số tiền gửi tối thiểu cần cập nhật

@Returns:
- 0: cập nhật thành công



# TABLE DEPOSITS: Bảng PHIEUGT

## Các tính năng liên quan đến gửi 
dbo.addDeposit : thêm phiếu gửi tiền, ngày mở phiếu, mã phiếu, status được thêm vào tự động \
@Params: 
- `CustomerID` INT : Mã khách hàng
- `InterestTypeID` INT : Mã LoaiTK
- `Fund` MONEY : Số tiền gửi 

@Returns:
- Record set (DepositID, OpenedDate, Term, InterestRate): thêm thành công, record set chứa những thông tin trừu tượng của phiếu gửi vừa tạo.
- 1: thêm không thành công vì chưa có khách hàng trong database hoặc không có loại tiết kiệm này trong database


<hr>

dbo.deleteDeposit : xóa phiếu gửi tiền \
@Params:
- `DepositID` INT : Mã phiếu gửi tiền cần xóa

@Returns: 
- 0: xóa thành công
- 1: không tồn tại phiếu gửi trong CSDL


<hr>

dbo.getDepositDetailWithDate : tìm phiếu gửi với ngày mở \
@Params:
- `OpenedDate` SMALLDATETIME : ngày mở theo định dạng YYYYMMDD

@Returns: 
- Record set (DepositID, CustomerID, CustomerName, CurrentBalance, OpenedDate) khi thành công



<hr>

dbo.getDepositDetailWithID : tìm phiếu gửi với MaPGT \
@Params:
- `DepositID` INT : MaGT

@Returns: 
- Record set (DepositID, CustomerID, CustomerName, CurrentBalance, OpenedDate) khi thành công



<hr>

dbo.getDepositDetailWithDateAndID : tìm phiếu gửi với ngày mở và MaPGT \
@Params:
- `DepositID` INT : MaGT
- `OpenedDate` SMALLDATETIME : ngày mở theo định dạng YYYYMMDD

@Returns: 
- Record set (DepositID, CustomerID, CustomerName, CurrentBalance, OpenedDate) khi thành công


<hr>
dbo.getDepositDetailWithCitizenID : tìm phiếu gửi với CCCD \
@Params:
- `CitizenID` INT : CCCD 

@Returns: 
- Record set (DepositID, CustomerID, CustomerName, CurrentBalance, OpenedDate) khi thành công


<hr>

dbo.searchDeposit: tra cứu phiếu gửi \
@Params:
- `DepositID` INT : MaGT (mặc định = NULL)
- `CitizenID` INT : CCCD (mặc định = NULL)
- `OpenedDate` SMALLDATETIME : ngày mở theo định dạng YYYYMMDD (mặc định = NULL) \
@Returns: 
- Record set (DepositID, CustomerID, CustomerName, CurrentBalance, OpenedDate) khi thành công, nếu DepositID khác NULL, chỉ trả về duy nhất 1 row, những trường hợp còn lại sẽ là kết hợp 


<hr>
dbo.getDeposit: lấy chi tiết phiếu gửi \
@Params:
- `DepositID` INT : MaGT \
@Returns: 
- Record set (CustomerID, CustomerName, CitizenID, PhoneNumber, CustomerAddress, DepositID, Fund, Term, InterestRate, TotalChanges,  CurrentBalance, OpenedDate, Withdrawer, WithdrawalDate) 

<hr>
dbo.sumActiveDeposit: tính tổng số tiền tiết kiệm đang gửi \
@Returns:
- Total : tổng số tiền đang gửi


## Các tính năng liên quan đến rút

dbo.addWithdrawal: lập phiếu rút tiền \
@Params:
- `DepositID` INT : mã phiếu gửi cần rút tiền
- `Withdrawer` VARCHAR(40) : tên người rút tiền

@Returns:
- Record set (BankInterest, Fund, Withdrawn, TransactionDate): chi tiết phiếu rút tiền
- 1: không có phiếu gửi `DepositID` trong CSDL


<hr>

dbo.deleteWithdrawal: hủy phiếu rút tiền \
@Params: 
- `DepositID` INT : phiếu gửi của phiếu rút tiền cần rút 

@Returns:
- 0: xóa thành công (nếu phiếu đã rút thì vẫn trả về 0)
- 1: không có phiếu gửi trong CSDL


# TABLE PROFITREPORTS + REPORTDETAILS: Bảng báo cáo ngày và chi tiết báo cáo ngày

dbo.makeReportByDay : tạo báo cáo ngày \
@Params:
- `Date` DATE: ngày lập báo cáo theo format dmy

@Returns 
- Hai Record sets: báo cáo và chi tiết ngày hôm đó nếu lập thành công
    + Báo cáo ngày (TotalRevenue, TotalCost, TotalProfit)
    + Báo cáo chi tiết (InterestTypeID, Revenue, Cost, Profit)

<hr>

dbo.summaryMonthReport : tổng hợp các báo cáo ngày thành 1 báo cáo tháng \
@Params:
- `Month` INT : tháng tổng hợp báo cáo
- `Year` INT : năm tổng hợp

@Returns:
- Record set (MonthRevenue, MonthCost, MonthProfit): báo cáo tháng đó nếu tổng hợp thành công, giá trị các bảng là NULL nếu ko có thông tin tháng đó 
- 1 : nếu tháng, năm không hợp lệ

