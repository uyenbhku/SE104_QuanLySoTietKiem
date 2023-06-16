# ĐỒ ÁN NHẬP MÔN CÔNG NGHỆ PHẦN MỀM - ĐỀ TÀI: QUẢN LÝ SỔ TIẾT KIỆM

### LỜI GIỚI THIỆU
Đây là đồ án cuối kỳ môn Nhập môn Công nghệ Phần mềm lớp SE104.N22, được thực hiện bởi nhóm 5 và dưới sự hướng dẫn của ThS. Đỗ Thị Thanh Tuyền.

#### Thành viên nhóm 5
|STT|Tên thành viên|MSSV|
|:-:|:-:|:-:|
|1|[Hoàng Anh Đức Đăng Quang](https://github.com/QuangHoang059)|21522509|
|2|[Bùi Huỳnh Kim Uyên](https://github.com/uyenbhku)|21521659|
|3|[Nguyễn Nguyên Giáp](https://github.com/Paignn)|21522025|
|4|[Nguyễn Bùi Thanh Mai](https://github.com/21522320)|21522320|
|5|[Đinh Tiến Đạt](https://github.com/GaChip)|19521330|

### THÔNG TIN CƠ BẢN
Đồ án đã sử dụng các công cụ/ngôn ngữ sau trong suốt quá trình thực hiện:
* Front-end: HTML, CSS và Javascript.
* Back-end: Javascript trên môi trường nodeJS.
* Cơ sở dữ liệu: SQL Server.

### CÁCH CHẠY PROJECT TRÊN LOCAL PC
Sau khi tải project từ github về máy tính cá nhân, ta cần thực hiện 1 số thao tác sau để có thể khởi chạy project:
* Đảm bảo máy đã cài đặt nodeJS và SQL Server.
* Bước 1: Trong Command prompt, sử dụng lệnh cd để tới folder của project.
* Bước 2: Trong Command prompt, sử dụng lệnh `npm i` để cài đặt các module cần thiết cho chương trình.
* Bước 3: Tạo database mới trong SQL Server, sau đó dùng các lệnh từ file `tables.sql` để tạo các table 
* Bước 4: Chạy `error_definition.sql` để định nghĩa các lỗi trong CSDL.
* Bước 5: Config cập nhật tự động bằng SQL Server Agent Jobs (chi tiết config có trong file `auto_update.sql`).
* Bước 6: Trong folder config, chỉnh sửa các thông tin của file `cnStr.js` đúng với thông tin của database đã được tạo(tên database, password,...).
* Bước 7: Phải start SQL Server Browser trên SQL Server 2022 Configuration Manager.
* Bước 8: Sau khi đã hoàn thành các bước trên, trong Command prompt, sử dụng lệnh `npm start` để server được khởi chạy, port đang sử dụng sẽ được thông báo, truy cập vào để xem kết quả.

<!-- ### VIDEO DEMO ĐỒ ÁN
[Link video demo](https://youtu.be/AUGFdoGetgI) -->

### MỘT SỐ CHỨC NĂNG CƠ BẢN CỦA ĐỒ ÁN (CURRENT STATUS)
* Đăng nhập tài khoản.
* Tạo phiếu gửi tiết kiệm với 3 loại tiết kiệm là: không kỳ hạn, kỳ hạn 3 tháng và kỳ hạn 6 tháng.
* Rút tiền với phiếu gửi tương ứng giữa kỳ, cuối kỳ.
* Cập nhật tiền lãi tự động, tự động tái tục.
* Thông báo biến động số dư, hiển thị rõ số tiền đã gửi/số tiền đã rút trong tháng.
* Lập báo cáo gửi/rút theo ngày.


### CÁC DỰ ĐỊNH PHÁT TRIỂN TIẾP THEO (FUTURE PLAN)
* Hoàn thiện hơn chức năng "tái tục"(Gửi lại sổ 1 lần nữa đối với những sổ đã đến kỳ hạn, tăng số lần gửi của sổ thêm 1)
* Hoàn thiện chức năng thông báo chi tiết biến động số dư, hiện tại server chỉ thông báo số tiền được gửi vào chứ chưa thông báo số tiền đã được rút ra, đồng thời cần phải xử lý database lại để chức năng thông báo biến động số dư hoạt động hiệu quả hơn, giảm số lần phải truy suất trong database.
* Chỉnh sửa lại các lỗi đã phát hiện ra trong quá trình testing.
* Tìm phương pháp deploy để project trở thành một phần mềm đúng nghĩa.
* Làm chức năng tạo báo cáo chi tiết trong tháng, nếu có thể sẽ nghiên cứu để xuất ra file. 

 
