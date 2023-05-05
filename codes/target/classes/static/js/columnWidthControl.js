// 控制列宽
$("th").mouseover(function (e) {
    if (($(this).find("div").length <= 0)) {
        //1.鼠标移动到表头上时，在th内部添加一个div 元素，用于处理后续拖动事件
        $(this).append("<div class='th-sisehandler'></div>")

        //2.处理上面添加的元素的鼠标按下事件
        $(".th-sisehandler").mousedown(function (evt) {
            //3.在添加的元素上按下时，记录下当前的th表头
            let dragTh = $(this).parent()

            //4.记录按下时的鼠标位置
            let oldClientX = evt.clientX;
            //5.获取当前鼠标按下时的表头的宽度
            let oldWidth = dragTh.width();
            /*6.添加一个全局layer层，用于处理鼠标按下时鼠标移动事件，因为不能在第一步添加的元素上处理鼠标移动事件，添加的元素太小，
                鼠标容易跑出范围，就捕获不到后续事件
                所以添加一个全局的遮罩层，捕获鼠标移动事件。
             */
            let changeSizeLayer = $('<div class="siselayer"></div>');
            $("body").append(changeSizeLayer);

            changeSizeLayer.on('mousemove', function (evt) {
                //7.处理遮罩层的鼠标移动事件，计算新的表头宽度
                var newWidth = evt.clientX - oldClientX + oldWidth;
                //设置新的宽度
                dragTh.attr('width', Math.max(newWidth, 1));

            });

            changeSizeLayer.on('mouseup', function (evt) {
                //8.鼠标按键复位时，要清楚遮罩层
                changeSizeLayer.remove();
                dragTh.find('.th-sisehandler').remove();
            });
        })
    }
    $(this).mouseleave(function () {
        //9.鼠标离开表头时，要移除第一步添加的div
        $(this).find("div").remove()
    })
})