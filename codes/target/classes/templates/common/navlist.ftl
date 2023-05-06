<#--<div class="col-md-12 green">-->
<div class="col-md-12" style="background-color: white">
	<!--导航栏左侧按钮，-->
	<ul class="nav navbar-nav navbar-left" style="margin-left: -15px;">
		<li><a href="#" class="green-none"><span
				class="glyphicon glyphicon-menu-hamburger black"></span></a></li>
	</ul>
	<!--右侧导航栏-->
	<ul class="nav navbar-nav navbar-right moredeep">

		<li><a href="http://117.72.11.14:3000/" style="font-size: 14px;color: black">ERP系统</a></li>

		<li><a href="javascript:changepath('/infromlist');" class="green-none black" title=" ${(notice)!''} 条通知未读">
				<span class="glyphicon glyphicon-bell"></span>
				</a>
		</li>
		<li><a href="javascript:changepath('/mail');" class="green-none black" title=" ${(mail)!''} 封邮件未读">
				<span class="glyphicon glyphicon-envelope"></span>
				</a>
		</li>
		<li><a href="javascript:changepath('/mytask');" class="green-none black" title=" ${(task)!''} 个任务未完成">
				<span class="glyphicon glyphicon-flag"></span>
				</a>
		</li>
		<li class="dropdown">
		<!--设置导航栏头像面板-->
		<a href="#" class="green-none black" data-toggle="dropdown">
				<img src="/image/${(user.imgPath)!'/timg.jpg'}" class="user-image" /> <span class="black">${user.userName}</span>
		</a> <!--设置点击按钮弹出用户面板层-->
			<ul class="dropdown-menu" style="padding:0;">
				<li class="user-header white"><img src="/image/${(user.imgPath)!'/timg.jpg'}"
					class="img-circle" style="width: 100px;height:100px;" />
					<p class="black" style="margin-top: 10px">
						<span>${user.dept.deptName} </span> / <span> ${user.role.roleName}</span><br> <small>${user.position.name}</small>
					</p></li>
				<li class="user-footer">
					<div class="pull-left">
						<a href="javascript:changepath('userpanel');" class="btn btn-default">用户面板</a>
					</div>
					<div class="pull-right">
						<a href="loginout" class="btn btn-danger">退出登录</a>
					</div>
				</li>
			</ul>
		</li>

		<li style="position: relative;"><a  id="history" class="green-none black" data-toggle="dropdown" title="历史记录"><span
				class="glyphicon glyphicon-time"></span></a>

		<ul id="historypanel" class="dropdown-menu"
				style="position: absolute; background-color: #222d32;">
				<#include "/user/userlog.ftl"/>
		</ul>
	</li>
</ul>
</div>
<script>
	function changeemail(){
		var email=$('.badge-mail').text().trim();
		var emailNum=parseInt(email);
		if(emailNum>1){
			$('.badge-mail').text((emailNum-1));
		}else{
			$('.badge-mail').text("");
		}
	}
	function changeinformation(){
		var email=$('.badge-notice').text().trim();
		var emailNum=parseInt(email);
		if(emailNum>1){
			$('.badge-notice').text((emailNum-1));
		}else{
			$('.badge-notice').text("");
		}
	}
	//从右往左滑动效果
	$(function() {
		var num = 1;
		$("#history").click(function() {
			num++;
			if (num % 2 == 0) {
				$("#historypanel").css({ //从右边飞入，使用绝对定位来操作 
					"width" : "230px",
					"right" : "-230px"
				}).show().animate({
					"right" : "0"
				}, "fast");
			} else
				$("#historypanel").animate({
					"width" : "toggle"
				}, "slow");
			$('#historypanel').load('/userlogs');

		})
	})
</script>