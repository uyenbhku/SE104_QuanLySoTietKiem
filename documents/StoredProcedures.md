# TABLE INTERESTTYPE : bảng LOAITK

dbo.addInterestType : thêm loại tiết kiệm \
@Params: 
- `InterestRate` DECIMAL(3,2) : Lãi suất mới 
- `Term` INT	: Kỳ hạn mới 
- `MinimumTimeToWithdrawal` INT (Optional, default = 0) : thời gian rút tối thiểu 

@Returns:
- 0: thêm thành công
- 1: thêm không thành công vì có loại tiết kiệm trùng kỳ hạn

<hr>

dbo.updateInterestType : cập nhật loại tiết kiệm \
@Params:
- `InterestTypeID` CHAR(10) : Mã loại tiết kiệm
- `NewInterestRate` DECIMAL(3,2) : Lãi suất mới (Optional)
- `NewMinimumTimeToWithdrawal` INT : Thời gian rút tối thiểu mới (Optional)

@Returns:
- 0: cập nhật thành công
- 1: cập nhật không thành công vì không có loại tiết kiệm tương ứng trong CSDL



# TABLE PARAMS : bảng THAMSO

dbo.updateMinimumDeposit : Cập nhật quy định số tiền gửi tối thiểu \
@Params:
- `NewMinimumDeposit` MONEY : số tiền gửi tối thiểu cần cập nhật
@Returns:
- 0: cập nhật thành công



# TABLE DEPOSITS: Bảng PHIEUGT

dbo.addDeposit : thêm phiếu gửi tiền, ngày mở phiếu, mã phiếu, status được thêm vào tự động \
@Params: 
- `CustomerID` CHAR(10) : Mã khách hàng
- `InterestTypeID` CHAR(10) : Mã LoaiTK
- `Fund` MONEY : Số tiền gửi 

@Returns:
- 0: thêm thành công
- 1: thêm không thành công vì chưa có khách hàng trong database
- 2: thêm không thành công vì không có loại tiết kiệm này trong database
- 3: thêm không thành công vì số tiền gửi nhỏ hơn quy định


dbo.deleteDeposit : xóa phiếu gửi tiền \
@Params:
- `DepositID` CHAR(10) : Mã phiếu gửi tiền cần xóa
@Returns: 
- 0: xóa thành công
- 1: xóa không thành công vì đã quá 30 phút lập phiếu và phiếu còn tiền, để xóa thì phải liên lạc SA
