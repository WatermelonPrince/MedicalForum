var digg = "0";
function initImages() {
    var images = document.getElementsByTagName('img');
    for (var i = 0; i < images.length; i++) {

        if (images[i].src == "") {
            images[i].setAttribute('height', '0px');
            continue;
        }

        if (images[i] == document.getElementById('xg_subscibe_icon')) {
            continue;
        }

        //images[i].removeAttribute('class');
        images[i].removeAttribute('style');
        images[i].removeAttribute('width');
        images[i].removeAttribute('height');
        images[i].removeAttribute('border');
        images[i].style.display = "block";
        images[i].onerror = function () {
            this.style.display = "none";
        };

        if (images[i].getAttribute("autoload") == "true") {
            loadImageDirectly(images[i]);//自动加载
        }

        //处理图片链接
        if (images[i].parentNode && images[i].parentNode.tagName == "A") {
            images[i].parentNode.setAttribute("href", 'javascript:void(0);');
            //images[i].parentNode.setAttribute('onclick', 'viewImage(this)');
            if (images[i].parentNode.parentNode.tagName == "P" && images[i].parentNode.parentNode.childNodes.length == 1) {
                images[i].parentNode.parentNode.style.textIndent = '0em';
            }
        } else {
           // images[i].setAttribute('onclick', 'viewImage(this)');
            if (images[i].parentNode.tagName == "P" && images[i].parentNode.childNodes.length == 1) {
                images[i].parentNode.style.textIndent = '0em';
            }
        }
    }

    var mode = document.getElementsByTagName('html')[0].getAttribute('class');
    initButtonIcon(mode);
    changeImageMode();
}

window.onload = function () {
    CMT.loadFinish();
};

function changeImageMode() {
    var images = document.getElementsByTagName('img');
    for (var i = 0; i < images.length; i++) {
        if (images[i].getAttribute("autoload") == "true") {
            CMT.changeCacheMode();
            break;
        }
    }
}

function loadImageDirectly(image) {
    var img = new Image();
    img.src = image.getAttribute("ori-src");
    if (img.complete) {
        image.src = image.getAttribute("ori-src");
    } else {
        img.src = "";
    }
}

function loadImageUrl(srcImage) {
    var img = new Image();

    img.onload = function () {
        img.onload = img.onerror = null;
        srcImage.src = srcImage.getAttribute("ori-src");
    };

    img.onerror = function () {
        CMT.displayMsg("图片加载失败，请点击重试");
        img.onload = img.onerror = null;
    };

    img.src = srcImage.getAttribute("ori-src");
}


function viewImage(i) {
    
   CMT.viewImages(i);
    
}

//改变字体大小
window.DEFAULT_FONTSIZE = 0;
window.setFontSize = function (fontSizeParam) {
    if (DEFAULT_FONTSIZE == 0) {
        DEFAULT_FONTSIZE = parseInt(getComputedStyle(document.body).fontSize);
    }

    var afterSize = (fontSizeParam*DEFAULT_FONTSIZE)/100;
    document.getElementById('content').style.fontSize = afterSize*1.7 + "px";

};

window.getContent = function () {
    return document.getElementById('content').innerHTML;
};
window.getAuthorName = function () {
    return document.getElementById('author_name').innerHTML;
};

window.setContent = function (content) {
    if (!content) {
        setLoadErrorState();
    } else if (content == 'error') {
        setLoadNetworkErrorState();
    } else {
        var contentObj = eval(content);
        content = contentObj.content;
        document.getElementById('xgtitle').style.display = "block";
        document.getElementById('xgdesp').style.display = "block";
        document.getElementById('content').innerHTML = content;
        initImages();
    }
};

window.setLoadedContent = function (content) {
    if (!content) {
        setLoadErrorState();
    } else if (content == 'error') {
        setLoadNetworkErrorState();
    } else {
        var contentObj = eval(content);
        document.getElementById('xgtitle').innerHTML = contentObj.xgtitle;
        document.getElementById('article_date').innerHTML = contentObj.article_date;
        document.getElementById('section_name').innerHTML = contentObj.section_name;
        document.getElementById('content').innerHTML = contentObj.content;
        document.getElementById('author_name').innerHTML = contentObj.author_name;

        document.getElementById('xgtitle').style.display = "block";
        document.getElementById('xgdesp').style.display = "block";
        init();
    }
};

function initButtonIcon(mode) {

}

window.setScreenMode = function (mode) {
    if (mode == "night") {
        document.getElementsByTagName('html')[0].setAttribute('class', 'night');
    } else {
        document.getElementsByTagName('html')[0].setAttribute('class', '');
    }

/**
    initButtonIcon(mode);

    var imgs = document.getElementsByTagName("img");
    for (i = 0; i < imgs.length; i++) {
        var img = imgs[i];
		img.setAttribute('ori-src', img.src);


        if (mode == "night") {
            if (img.src.indexOf("xg_default_icon_click.png") != -1) {
                img.src = "./xgimage/night_xg_default_icon_click.png";
            }
        } else {
            if (img.src.indexOf("night_xg_default_icon_click.png") != -1) {
                img.src = "./xgimage/xg_default_icon_click.png";
            }
        }
    }
    
*/


};

// 替换图片
window.updateImage = function(oldUrl, newUrl) {

 	var imgs = document.getElementsByTagName("img");
 	
    for (i = 0; i < imgs.length; i++) {
        var img = imgs[i];
		if(img.getAttribute('ori-src') == oldUrl) {
			img.src = newUrl;
			img.setAttribute('ori-src', newUrl);
			break;
		}
		
	}
}

// 替换图片
function replaceImage(oldUrl, newUrl) {
    
    var imgs = window.document.getElementsByTagName("img");
    
    for (i = 0; i < imgs.length; i++) {
        var img = imgs[i];
        if(img.getAttribute('ori-src') == oldUrl) {
            img.src = newUrl;
            img.setAttribute('ori-src', newUrl);
            break;
        }
        
    }
}

function replaceFace(newUrl) {

    var imgs = window.document.getElementsByTagName("img");
    
    for (i = 0; i < imgs.length; i++) {
        var img = imgs[i];
        if(img.getAttribute('ori-src') == "face.png") {
            img.src = newUrl;
            break;
        }
        
    }
}

function setLoadingState() {
    content = '<div class="content-loading">正在加载...</div>';
    document.getElementById('content').innerHTML = content;
    document.getElementById('xgtitle').style.display = "none";
    document.getElementById('xgdesp').style.display = "none";
}

function setLoadErrorState() {
    content = "<div class='content-loading' style='text-decoration:underline;' onclick='refreshArticle()'>加载失败，点击刷新</div>"
    document.getElementById('content').innerHTML = content;
}

function setLoadNetworkErrorState() {
    content = "<div class='content-loading' style='text-decoration:underline;' onclick='refreshArticle()'>网络未连接，点击重试</div>"
    document.getElementById('content').innerHTML = content;
}

function refreshArticle() {
    setLoadingState();
    CMT.refresh();
}
function init() {
    if (getContent().trim() == "") {
        setLoadingState();
    }

    //根据屏幕大小调整，字体大小
    var screenSize = parseInt(document.getElementById("screen-size").innerText);
    var htmlPadding = "";
    var recommendPadding = "";
    switch (screenSize) {
        case 1:
            htmlPadding = "0 5%";
            recommendPadding = "5%";
            break;
        case 2:
            htmlPadding = "0 8%";
            recommendPadding = "8%";
            break;
        case 3:
            htmlPadding = "0 10%";
            recommendPadding = "10%";
            break;
        default:
            htmlPadding = "0 5%";
            recommendPadding = "5%";
            break;
    }
    if (htmlPadding) {
        document.getElementById('xg_head_content').style.padding = htmlPadding;
        document.getElementById('content').style.padding = htmlPadding;


    }

    //根据用户设置调整body字体
    var customFontsize = parseInt(document.getElementById("custom-fontsize").innerText);
    digg = parseInt(document.getElementById("digg").innerText);

    setFontSize(customFontsize);

    //显示文章
    document.getElementById('wrapper').style.display = "block";


    initImages();
}

function video(obj) {
    CMT.video(obj.getAttribute("data"));
}

function loadData() {
    init();
    window.onChange = init;
}

//subscribe the target section
function subscibeIt(sectionId, sectionName) {
    CMT.subscribeTheSection(sectionId, sectionName);
}

function top_it() {
    CMT.topIt();
}
function tread_it() {
    CMT.treadIt();
}


function viewDetail(obj) {
    CMT.viewDetail(obj.getAttribute("data"));
}

function jumpUrl(obj){
    var data = obj.getAttribute("data");
    var type = obj.getAttribute("type");
    CMT.jumpUrl(data,type);
}
function setStatus(id,n){
	if(n == 0){
		document.getElementById(id).className = "wait";	
	}else if(n == 1){
		document.getElementById(id).className = "complete";	
	}else{
		document.getElementById(id).className = "";	
	}		
}
//设置图片高度
function setImagesHeihgt(n,m,h) {
    var images =  document.getElementById('content').getElementsByTagName('img');
    images[n].style.height = h + "px";
    images[n].style.width = m + "px";
}