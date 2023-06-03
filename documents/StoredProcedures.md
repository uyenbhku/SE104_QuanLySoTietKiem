** Ở trên API nhớ xử lý SQL Injection nha :))) SQL Injection: https://bobby-tables.com/

# TABLE INTERESTTYPES : bảng LOAITK

dbo.addInterestType : thêm loại tiết kiệm \
@Params: 
- `InterestRate` DECIMAL(3,2) : Lãi suất mới 
- `Term` INT	: Kỳ hạn mới 
- `MinimumTimeToWithdrawal` INT (Optional, default = 0) : thời gian rút tối thiểu 

@Returns:
- 0: thêm thành công
- 1: Lỗi gì đó

<hr>

dbo.updateInterestType : cập nhật loại tiết kiệm \
@Params:
- `InterestTypeID` CHAR(10) : Mã loại tiết kiệm
- `NewInterestRate` DECIMAL(3,2) : Lãi suất mới (Optional)
- `NewMinimumTimeToWithdrawal` INT : Thời gian rút tối thiểu mới (Optional)

@Returns:
- 0: cập nhật thành công
- 1: cập nhật không thành công vì đã có loại tiết kiệm tương ứng trong CSDL
- 2: Lỗi gì đó

<hr>

dbo.blockInterestType : "khóa" loại tiết kiệm \
@Params:
- `InterestTypeID` CHAR(10) : Mã loại tiết kiệm

@Returns:
- 0: cập nhật thành công

<hr>

dbo.unblockInterestType : "mở khóa" loại tiết kiệm \
@Params:
- `InterestTypeID` CHAR(10) : Mã loại tiết kiệm

@Returns:
- 0: cập nhật thành công



# TABLE PARAMS : bảng THAMSO

dbo.updateMinimumDeposit : Cập nhật quy định số tiền gửi tối thiểu \
@Params:
- `NewMinimumDeposit` TEXT : số tiền gửi tối thiểu cần cập nhật

@Returns:
- 0: cập nhật thành công
- 1: cập nhật không thành công vì lỗi dữ liệu



# TABLE DEPOSITS: Bảng PHIEUGT

dbo.addDeposit : thêm phiếu gửi tiền, ngày mở phiếu, mã phiếu, status được thêm vào tự động \
@Params: 
- `CustomerID` CHAR(10) : Mã khách hàng
- `InterestTypeID` CHAR(10) : Mã LoaiTK
- `Fund` MONEY : Số tiền gửi 

@Returns:
- 0: thêm thành công
- 1: thêm không thành công vì chưa có khách hàng trong database hoặc không có loại tiết kiệm này trong database
- 2: thêm không thành công vì số tiền gửi nhỏ hơn quy định

<hr>

dbo.deleteDeposit : xóa phiếu gửi tiền \
@Params:
- `DepositID` CHAR(10) : Mã phiếu gửi tiền cần xóa

@Returns: 
- 0: xóa thành công
- 1: xóa không thành công vì đã quá 30 phút lập phiếu và phiếu còn tiền, để xóa thì phải liên lạc SA


<hr>

dbo.getDepositDetailWithDate : tìm phiếu gửi với ngày mở \
@Params:
- `OpenedDate` SMALLDATETIME : ngày mở theo định dạng YYYYMMDD

@Returns: 
- Record set 


<hr>

dbo.getDepositDetailWithID : tìm phiếu gửi với MaPGT \
@Params:
- `DepositID` CHAR(10) : MaGT

@Returns: 
- Record set 


<hr>

dbo.getDepositDetailWithDateAndID : tìm phiếu gửi với ngày mở và MaPGT \
@Params:
- `DepositID` CHAR(10) : MaGT
- `OpenedDate` SMALLDATETIME : ngày mở theo định dạng YYYYMMDD

@Returns: 
- Record set 


# TABLE PROFITREPORTS + REPORTDETAILS: Bảng báo cáo ngày và chi tiết báo cáo ngày\

dbo.makeReportByDay : tạo báo cáo ngày \
@Params:
- `Date` DATE: ngày lập báo cáo theo format dmy

@Returns 
- Record set: nếu lập thành công
- 1: nếu ngày lập báo cáo ở tương lai (> hiện tại)

dbo.summaryMonthReport : tổng hợp các báo cáo ngày thành 1 báo cáo tháng \
@Params:
- `Month` INT : tháng tổng hợp báo cáo
- `Year` INT : năm tổng hợp

@Returns:
- Record set : nếu tổng hợp thành công
- 1 : nếu tháng, năm không hợp lệ



# TABLE CUSTOMER : bảng KHACHHANG

dbo.addCustomer : thêm khách hàng \
@Params: 
- `CustomerName` VARCHAR(40) : Tên khách hàng 
- `PhoneNumber` VARCHAR(20)	: Số điện thoại 
- `CitizenID` VARCHAR(20) : Căn cước công dân
- `CustomerAddress` VARCHAR(100) : Địa chỉ

@Returns:
- Record set: thêm thành công
- 1: thêm không thành công vì bị trùng căn cước công dân
- 2: Lỗi gì đó (có thể do tham số truyền vào bị null)

<hr>

dbo.updateCustomer : cập nhật khách hàng \
@Params: 
- `CustomerID` INT : Mã khách hàng
- `CustomerName` VARCHAR(40) : Tên khách hàng mới 
- `PhoneNumber` VARCHAR(20)	: Số điện thoại mới
- `CitizenID` VARCHAR(20) : Căn cước công dân mới
- `CustomerAddress` VARCHAR(100) : Địa chỉ mới

@Returns:
- 0: cập nhật thành công
- 1: Không có sự cập nhật nào xảy ra do tất cả các tham số truyền vào đều là null hoặc không tồn tại mã khách hàng cần cập nhật trong CSDL
- 2: cập nhật không thành công vì bị trùng căn cước công dân
- 3: Lỗi gì đó 

<hr>

dbo.getCustomerDetailWithCitizenID : tìm khách hàng với CCCD \
@Params:
- `CitizenID` INT : Căn cước công dân

@Returns: 
- Record set: tìm kiếm thành công
- 1: Lỗi gì đó



