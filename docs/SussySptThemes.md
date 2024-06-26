
# SussySpt Themes

## Example
```lua
{
    ImGuiCol = {
        Option1 = {0, 100, 200}, -- {red, green, blue}
        Option2 = {0, 100, 200, 255} -- {red, green, blue, alpha}
    },
    ImGuiStyleVar = {
        Option1 = {0}, -- {value1}
        Option2 = {1, 2} -- {value1, value2}
    }
}
```

## Available options
*the descriptions may not be accurate*


### ImGuiCol
`{red: 0-255 float, green: 0-255 float, blue: 0-255 float, alpha: 0-255 float}`
- Text: The color of the text
- TextDisabled: The color of disabled text
- WindowBg: The background color of windows
- ChildBg: The background color of child windows
- PopupBg: The background color of popups
- Border: The color of borders
- BorderShadow: The color of border shadows
- FrameBg: The background color of frames
- FrameBgHovered: The background color of frames when hovered
- FrameBgActive: The background color of frames when active
- TitleBg: The background color of window titles
- TitleBgActive: The background color of active window titles
- TitleBgCollapsed: The background color of collapsed window titles
- MenuBarBg: The background color of the menu bar
- ScrollbarBg: The background color of scrollbars
- ScrollbarGrab: The color of scrollbar grabber
- ScrollbarGrabHovered: The color of scrollbar grabber when hovered
- ScrollbarGrabActive: The color of scrollbar grabber when active
- CheckMark: The color of check marks
- SliderGrab: The color of slider grabber
- SliderGrabActive: The color of slider grabber when active
- Button: The color of buttons
- ButtonHovered: The color of buttons when hovered
- ButtonActive: The color of buttons when active
- Header: The color of headers
- HeaderHovered: The color of headers when hovered
- HeaderActive: The color of headers when active
- Separator: The color of separators
- SeparatorHovered: The color of separators when hovered
- SeparatorActive: The color of separators when active
- ResizeGrip: The color of resize grips
- ResizeGripHovered: The color of resize grips when hovered
- ResizeGripActive: The color of resize grips when active
- Tab: The color of tabs
- TabHovered: The color of tabs when hovered
- TabActive: The color of active tabs
- TabUnfocused: The color of unfocused tabs
- TabUnfocusedActive: The color of active unfocused tabs
- PlotLines: The color of plot lines
- PlotLinesHovered: The color of plot lines when hovered
- PlotHistogram: The color of plot histograms
- PlotHistogramHovered: The color of plot histograms when hovered
- TableHeaderBg: The background color of table headers
- TableBorderStrong: The color of strong table borders
- TableBorderLight: The color of light table borders
- TableRowBg: The background color of table rows
- TableRowBgAlt: The background color of alternating table rows
- TextSelectedBg: The background color of selected text
- DragDropTarget: The color of drag-and-drop targets
- NavHighlight: The color of navigation highlights
- NavWindowingHighlight: The color of windowing navigation highlights
- NavWindowingDimBg: The dim background color of windowing navigation
- ModalWindowDimBg: The dim background color of modal windows

### ImGuiStyleVar
`{v1: float, v2: float}`
- Alpha: Global alpha applies to everything
- DisabledAlpha: Global alpha for disabled widgets
- WindowPadding: Padding for all windows
- WindowRounding: Radius of window corners rounding
- WindowBorderSize: Thickness of border around windows
- WindowMinSize: Minimum size for windows
- WindowTitleAlign: Alignment for title bar text
- ChildRounding: Radius of child window corners rounding
- ChildBorderSize: Thickness of border around child windows
- PopupRounding: Radius of popup window corners rounding
- PopupBorderSize: Thickness of border around popup windows
- FramePadding: Padding for widget frames
- FrameRounding: Radius of frame corners rounding
- FrameBorderSize: Thickness of border around widget frames
- ItemSpacing: Spacing between widgets
- ItemInnerSpacing: Spacing between elements of a composed widget
- IndentSpacing: Horizontal spacing used for indenting elements
- CellPadding: Padding within a table cell
- ScrollbarSize: Width/Height of the vertical/horizontal scrollbar
- ScrollbarRounding: Radius of scrollbar corners rounding
- GrabMinSize: Minimum width/height of a vertical/horizontal scrollbar
- GrabRounding: Radius of grab corners rounding
- TabRounding: Radius of tab corners rounding
- SelectableTextAlign: Alignment of text within a selectable
- ButtonTextAlign: Alignment of text within a button
