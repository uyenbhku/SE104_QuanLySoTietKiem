printJS({
    printable: 'main',
    type: 'html',
    documentTitle: 'Phiếu Gửi Tiền',
    onPrintDialogClose: () => {
        window.close()
        // window.location.reload('./deposit')
    }
})