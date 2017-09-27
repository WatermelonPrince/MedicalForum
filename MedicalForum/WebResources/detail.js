$(document).ready(function(e) {
    $(".add_comment a").click(function(event){
		var thisX = event.pageX,
			thisY = event.pageY,
			thisScrollTop = document.body.scrollTop;
			location.href = "cmtopdr://postDetail?action=appendDetailsCoordinate&x="+ event.pageX +"&y="+ (event.pageY-thisScrollTop);	
	});
});

//获取追加评论按钮高度
function addComment(){
    return $(".add_comment a").offset().top+$(".add_comment a").height();
}
//显示追加按钮
function showComment(){
	$(".author .author_cnt .author_btn").show();
    $(".author span").css("padding-right","150px");
}
//显示筛选按评论钮
function showFilter(){
	$(".filter").show();
	return getHeight();
}
//隐藏筛选按评论钮
function hideFilter(){
    $(".filter").hide();
    return getHeight();
}
//status:1有赞过,0没有赞过
function isPraise(status){
	if(status){
		$(".filter a").addClass("on");
	}else{
		$(".filter a").removeClass("on");	
	}
}
//status:1全部,0赞过的
function filter(status){
	if(status){
		$(".filter a").text("全部评论").attr("href","cmtopdr://postDetail?action=zan&flag=1");
	}else{
		$(".filter a").text("我赞过的").attr("href","cmtopdr://postDetail?action=zan");	
	}
}

function showFace(img){
	$(".author .face img").attr("src",img);	
}
//addContent(0以前的/1最近的/2完结的,时间,内容);
function addContent(status,date,data){
	var clazz = "";
	if(status == 0){
		clazz = "prev";
	}else if(status == 1){
		clazz = "now";	
	}else if(status == 2){
		clazz = "next";	
	}
	$(".add_content").show().append("<div class="+ clazz +"><em>"+ date +"</em>"+ data +"</div>");
	
	return getHeight();
}

//获取页面高度
function getHeight(){
//	var thisHeight = window.document.body.offsetHeight;
//	CMT.getHeight(thisHeight);
    return window.document.body.offsetHeight;
}
//获取点赞过滤按钮的最底部位置
function getfilteButtonbottom(){
    return $(".filter a").offset().top+$(".filter a").height();
}
////获取点赞过滤按钮的最顶部位置
function setfilteButtonTop(padding){
    $(".filter").css("padding-top",padding+"px");
}
//设置位置



