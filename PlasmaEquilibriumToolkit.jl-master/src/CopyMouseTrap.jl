using Mousetrap, Plots, NetCDF, VMEC, StructArrays

include("Cplot.jl")
include("NetCDFUtils.jl")   
include("Surface2D.jl")
import .CPlot: data

main() do app::Application
    window = Window(app)
    picture = Window(app)
    set_title!(window, "Wisc.Edu")
    header_bar = get_header_bar(window)
    swap_button = Button()
    set_tooltip_text!(swap_button, "Click to Swap Themes")
    connect_signal_clicked!(swap_button, app) do self::Button, app::Application

        # get currently used theme
        current = get_current_theme(app)

        # swap light with dark, preservng whether the theme is high contrast
        if current == THEME_DEFAULT_DARK
            next = THEME_DEFAULT_LIGHT
        elseif current == THEME_DEFAULT_LIGHT
            next = THEME_DEFAULT_DARK
        elseif current == THEME_HIGH_CONTRAST_DARK
            next = THEME_HIGH_CONTRAST_LIGHT
        elseif current == THEME_HIGH_CONTRAST_LIGHT
            next = THEME_HIGH_CONTRAST_DARK
        end

        # set new theme
        set_current_theme!(app, next)
    end
    push_front!(header_bar, swap_button)

    vector2f = Vector2f(500, 500)
    set_size_request!(window, vector2f)
    button = Button()
    set_size_request!(button, Vector2f(5, 5))
    box_a = FlowBox(ORIENTATION_VERTICAL)
    set_child!(button, Label("Open File"))

    vtype = readVmecWout("C:/Users/Jay/Downloads/wout_aten.nc")
    file_chooser = FileChooser()
    filter = FileFilter("*.nc")   
    add_allowed_suffix!(filter, "nc")
    add_filter!(file_chooser, filter)
    on_accept!(file_chooser) do self::FileChooser, files
        vtype = readVmecWout("C:/Users/Jay/Downloads/wout_aten.nc")
        println("selected files: $files")

    end

    connect_signal_clicked!(button) do button
        present!(file_chooser)
    end
    push_back!(box_a, button)
    set_expand!(box_a, false)
    set_expand!(button, false)

    Cord = DropDown()
    item_01_id = push_back!(Cord, "Flux")
    item_02_id = push_back!(Cord, "Clebsch")
    item_03_id = push_back!(Cord, "Pest")
    item_04_id = push_back!(Cord, "Boozer")
    set_margin_top!(Cord, 10)
    push_back!(box_a, Cord)

    spin_button1 = SpinButton(0,1,0.1)
    spin_button2 = SpinButton(0,2pi,0.1)
    spin_button3 = SpinButton(0,2pi,0.1)
    spin_button4 = SpinButton(0,50,1)

    push_back!(box_a, spin_button1) 

    set_margin_top!(spin_button1, 10)

    center_box = CenterBox(ORIENTATION_HORIZONTAL)
    set_start_child!(center_box, spin_button2)
    set_center_child!(center_box, spin_button3) 
    set_end_child!(center_box, spin_button4)
    push_back!(box_a, center_box)

    set_margin_top!(center_box, 10)
    set_margin_end!(spin_button2, 10)
    set_margin_end!(spin_button3, 10)


    mfield = DropDown()

    item_01_id = push_back!(mfield, "B_norm")
    set_margin_top!(mfield, 10)
    push_back!(box_a, mfield)

    button2 = Button()
    set_size_request!(button2, Vector2f(5, 5))
    set_child!(button2, Label("Generate"))
    set_margin_top!(button2, 10)


    s = 0.5
    theta = range(start = 0, stop = 2pi, length = 25)
    zeta = range(start = 0, stop = 2pi, length = 25)
    bmag_2D_line_contour(vtype, s, theta, zeta)


    connect_signal_clicked!(button2) do button2
        img = Image()
        create_from_file!(img, "C:/Users/Jay/Downloads/julia4ta tutorials c74374ec261ebde84c14dbee9ef0aea4375ff1ec Series%2004-Tutorial%2004x03/Series 04/Tutorial 04x03/FinalPlot.png")
        image_display = ImageDisplay()
        create_from_image!(image_display, img)
        set_child!(picture, image_display)
        set_size_request!(picture, Vector2f(500, 500))
        present!(picture)
    end

    push_back!(box_a, button2)

    set_horizontal_alignment!(box_a, ALIGNMENT_CENTER)

    set_child!(window, box_a)
    

    present!(window)
end