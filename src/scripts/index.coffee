class Circle
  constructor: (data) ->
    @color = data.color
    @center =
      x: data.center.x
      y: data.center.y
    @radius = data.radius

  checkPointInCircle: (x, y)->
    squaredDistance =
      (x - @center.x) * (x - @center.x) + (y - @center.y) * (y - @center.y)
    return squaredDistance <= @radius * @radius


class ColorPickup
  constructor: (selector, opts)->
    @el = document.querySelector(selector)
    @selectCanvas = @el.querySelector(".ColorPickup_select")
    @targetCanvas = @el.querySelector(".ColorPickup_target")
    @addedCircles = []
    @colors = opts.colors
    @circlesPerRow = opts.circlesPerRow || 3
    @_init()

  _drawCircle: (params) ->
    context = @selectCanvas.getContext('2d')
    context.beginPath()
    context.arc(
      params.center.x
      params.center.y
      params.radius
      0, 2 * Math.PI
      false
    )
    context.fillStyle = params.color
    context.fill()

    return

  setSelectedColor: (color)->
    # @selectedColor = color
    ctx = @targetCanvas.getContext("2d")
    ctx.fillStyle = color
    ctx.fillRect(0, 0, @targetCanvas.width, @targetCanvas.height)
    return

  _fillCanvasWithCircles: ()->
    gutter = (@selectCanvas.width / 100) * 2.5
    circleDiameter =
      (@selectCanvas.width - (gutter * (@circlesPerRow + 1))) / @circlesPerRow
    circleRadius = circleDiameter / 2
    lastCenter = {
      x: gutter
      y: -circleRadius
    }

    for color, index in @colors
      isFirstInRow = index % @circlesPerRow is 0
      if isFirstInRow
        lastCenter.y += circleDiameter + gutter
        lastCenter.x = gutter + circleRadius
      else
        lastCenter.x += circleDiameter + gutter

      params =
        color: color
        radius: circleRadius
        center:
          x: lastCenter.x
          y: lastCenter.y

      @_drawCircle(params)

      @addedCircles.push new Circle({
        center: {
          x: lastCenter.x
          y: lastCenter.y
        }
        color: color,
        radius: circleRadius,
      })
    return

  

  _bindClicks: ()->
    @selectCanvas.addEventListener "click", (event)=>
      el = event.currentTarget
      scaleFactor = el.offsetWidth / el.width
      viewportOffset = el.getBoundingClientRect()
      clickX =
        Math.round(
          (event.pageX - viewportOffset.left - window.pageXOffset) / scaleFactor
        )
      clickY =
        Math.round(
          (event.pageY - viewportOffset.top - window.pageYOffset)  / scaleFactor
        )

      selectedColor = "#fff"
      
      for c in @addedCircles
        if c.checkPointInCircle(clickX, clickY)
          selectedColor = c.color
          break

      @setSelectedColor(selectedColor)
      return

  _init: ()->
    @_fillCanvasWithCircles()
    @_bindClicks()



new ColorPickup("#colorPickup", {
  circlesPerRow: 3
  colors: [
    "#FF3333"
    "#0033CC"
    "#00CC66"
    "#FFFF33"
    "#000000"
    ]
  }
)