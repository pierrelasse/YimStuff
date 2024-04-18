return {
    Nightly = { -- ANCHOR Nightly
        ImGuiCol = {
            TitleBg = {9, 27, 46, 255},
            TitleBgActive = {9, 27, 46, 255},
            WindowBg = {0, 19, 37, 242},
            Tab = {10, 30, 46, 255},
            TabActive = {14, 60, 90, 255},
            TabHovered = {52, 64, 71, 255},
            Button = {3, 45, 79, 255},
            FrameBg = {35, 38, 53, 255},
            FrameBgHovered = {37, 40, 55, 255},
            FrameBgActive = {37, 40, 55, 255},
            HeaderActive = {54, 55, 66, 255},
            HeaderHovered = {62, 63, 73, 255}
        },
        ImGuiStyleVar = {WindowRounding = {4}, FrameRounding = {2}}
    },
    Dark = { -- ANCHOR Dark
        ImGuiCol = {
            TitleBg = {18, 18, 18, 247},
            TitleBgActive = {21, 21, 22, 247},
            WindowBg = {18, 18, 18, 247},
            Tab = {42, 42, 42, 204},
            TabActive = {134, 134, 134, 255},
            TabHovered = {147, 147, 147, 255},
            Button = {42, 42, 42, 204},
            FrameBg = {32, 32, 32, 255},
            FrameBgHovered = {34, 34, 34, 255},
            FrameBgActive = {34, 34, 34, 255}
        },
        ImGuiStyleVar = {WindowRounding = {8}, FrameRounding = {5}}
    },
    Purple = { -- ANCHOR Purple
        ImGuiCol = {
            TitleBg = {11, 5, 37, 191},
            TitleBgActive = {21, 8, 47, 206},
            WindowBg = {21, 8, 47, 209},
            Tab = {41, 25, 80, 127},
            TabActive = {55, 29, 124, 127},
            TabHovered = {51, 35, 90, 128},
            Button = {94, 57, 186, 76},
            FrameBg = {41, 25, 80, 171},
            FrameBgHovered = {41, 35, 90, 171},
            FrameBgActive = {41, 35, 90, 171}
        },
        ImGuiStyleVar = {WindowRounding = {16}, FrameRounding = {3}}
    },
    Fatality = { -- ANCHOR Fatality
        ImGuiCol = {
            TitleBg = {9, 6, 20, 191},
            TitleBgActive = {9, 6, 20, 217},
            WindowBg = {19, 13, 43, 222},
            Tab = {239, 7, 73, 127},
            TabActive = {255, 59, 115, 127},
            TabHovered = {255, 59, 115, 128},
            Button = {239, 7, 73, 76},
            FrameBg = {26, 29, 48, 171},
            FrameBgHovered = {16, 22, 48, 171},
            FrameBgActive = {13, 15, 48, 171},
            Border = {32, 20, 60, 193}
        },
        ImGuiStyleVar = {WindowRounding = {5}, FrameRounding = {2.5}}
    },
    FatalityBorderTest = { -- ANCHOR FatalityBorderTest
        parent = "Fatality",
        ImGuiCol = {BorderShadow = {0, 0, 0, 0}},
        ImGuiStyleVar = {FrameBorderSize = {4.05}}
    }
};
