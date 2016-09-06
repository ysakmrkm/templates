# スムーススクロール関数モーション定義
jQuery.extend(
  jQuery.easing,{
    easeInOutCirc:
      (x, t, b, c, d) ->
        if (t/=d/2) < 1
          return -c/2 * (Math.sqrt(1 - t*t) - 1) + b
        c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b
  }
)

$(()->
  $id = $('body').attr('id')
  $class = $('body').attr('class')

  # フッター高さ取得
  footerHeight =
    ()->
      add = 0
      height = $('#footer').height()
      outerHeight = $('#footer').outerHeight(true)
      diff = height - outerHeight
      if diff > 0
        $('#content').css('padding-bottom',height+add)
        $('#footer').css('height',height)
      else
        $('#content').css('padding-bottom',outerHeight+add)
        $('#footer').css('height',height)
      return

  footerHeight()

  $(window).on('load resize',
    ->
      footerHeight()
  )

  $('a[href^="#"]'+'a[href!="#"]').on('click.smoothScroll'
    (e)->
      $(
        if (navigator.userAgent.indexOf('Opera') isnt -1)
        then (
          if document.compatMode is 'BackCompat'
          then 'body'
          else 'html'
        )
        else 'html,body'
      ).animate({
        scrollTop:$($(this).attr('href')).offset().top - 20
      },{
        easing:'easeInOutCirc',
        duration:1000
      })

      e.preventDefault()
      return
  )
