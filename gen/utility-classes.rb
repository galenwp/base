GENFILE = "../sass/utilities.scss"

PROPERTIES = [{         # Properties we want to generate
  name: "width",        # Name of CSS property
  shorthand: "w",       # Name of CSS class (IE, .w8)
  maximum: 100,         # Maximum value of property (IE, .w100)
  multiple: 1           # Only generate multiples of this number (2 = .w2, .w4, .w6...)
}, {
  name: "height",
  shorthand: "h",
  maximum: 100,
  multiple: 1
}, {
  name: "margin",
  shorthand: "m",
  multiple: 1,
  maximum: 100,
  all_sides: true
}, {
  name: "padding",
  shorthand: "p",
  multiple: 1,
  maximum: 100,
  all_sides: true
}]

def main
  css_objects = generate_classes(PROPERTIES)
  print_classes(css_objects)
end

def generate_classes (props)
  css_objs = {} # Array of objects that represent CSS classes, grouped by property

  props.each do |prop|
    css_objs[prop[:name]] = {}

    if prop[:all_sides]
      css_objs[prop[:name]][:classes] = gen_multiple(prop).concat(gen_single(prop))
    else
      css_objs[prop[:name]][:classes] = gen_single(prop)
    end
  end

  return css_objs
end

def gen_single(prop)
  css_classes = []  # Individual CSS classes

  num_classes = prop[:maximum] / prop[:multiple]
  num_classes.times do |i|
    value = i * prop[:multiple]
    css_classes.push({
      identifier: ".#{prop[:shorthand]}-#{value}",
      prop_name: "#{prop[:name]}",
      prop_value: "#{value}rem"
    })
  end

  return css_classes
end

def gen_multiple (prop)
  css_classes = []  # Individual CSS classes

  sides = [{
    name: "left",
    shorthand: "l"
  }, {
    name: "right",
    shorthand: "r"
  }, {
    name: "top",
    shorthand: "t"
  }, {
    name: "bottom",
    shorthand: "b"
  }]

  sides.each do |side|
    side_prop = prop.clone()

    side_prop[:shorthand] = "#{prop[:shorthand]}#{side[:shorthand]}"
    side_prop[:name] = "#{prop[:name]}-#{side[:name]}"
    side_classes = gen_single(side_prop)
    css_classes.concat(side_classes)
  end

  return css_classes
end

def section_template(name)
  %(
/**********************
  #{name.capitalize} classes
**********************/
  )
end

def class_template(css_class)
  %(
#{css_class[:identifier]} {
  #{css_class[:prop_name]}: #{css_class[:prop_value]};
}
  )
end

def print_classes (prop_groups)
  big_css_string = ""

  prop_groups.each do |name, group|
    big_css_string += section_template(name)

    group[:classes].each do |css_class|
      big_css_string += class_template(css_class)
    end
  end

  File.open(GENFILE, "w") { |file| file.write(big_css_string) }
end

main()
