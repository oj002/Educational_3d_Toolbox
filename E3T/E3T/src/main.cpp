#include "Core.hpp"

int width = 800, height = 600;
bool E3T_wnd_open{ false };

Cam cam(glm::vec3(0.0f, 0.0f, 3.0f));
float dt = 0.0f;

void processInput(GLFWwindow *pWindow);
void mouse_callback(GLFWwindow * window, double xpos, double ypos);
void window_size_callback(GLFWwindow* window, int w, int h) noexcept;

struct point
{
	point(double x, double y, std::string name) : coord(x,y), name(name) {}
	glm::vec2 coord;
	std::string name;
};

int main()
{{
	E3T::init_glfw();


	GLFWwindow* pWindow{ E3T::createWindow(width, height, "E3T") };
	glfwMakeContextCurrent(pWindow);
	glfwSetWindowSizeCallback(pWindow, window_size_callback);
	glfwSetCursorPosCallback(pWindow, mouse_callback);

	E3T::init_glad();
	glViewport(0, 0, width, height);


	// One big triangle that covers the howl screen
	// Automatic clipping at 0 cost
	// faster than drawing 2 triangles or one quad (gets converted to 2 triangles)
	// because no overlapping pixels will get rendered twice
	const float vertices[] = {
		-1.0f,-1.0f,
		-1.0f, 3.0f,
		 3.0f,-1.0f
	};

	GLuint vao, vbo;
	glGenVertexArrays(1, &vao);
	glGenBuffers(1, &vbo);

	glBindVertexArray(vao);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), nullptr);
	glEnableVertexAttribArray(0);


	E3T::init_imgui(pWindow);

	E3T::Shader shader;
	shader.bind();

	E3T::Timer timer;
	E3T::Timer dtTimer;
	while (!glfwWindowShouldClose(pWindow))
	{
		dt = dtTimer.restart<float>();

		ImGui_ImplOpenGL3_NewFrame();
		ImGui_ImplGlfw_NewFrame();
		ImGui::NewFrame();


		GLCall(glClear(GL_COLOR_BUFFER_BIT));


		shader.update("main.glsl");
		shader.setVec3("u_camUp", cam.up);
		shader.setVec3("u_camRight", cam.right);
		shader.setVec3("u_eye", cam.position);
		shader.setFloat("u_time", timer.getElapsedTime<float>());
		shader.setFloat("u_dt", dt);
		shader.setVec2("u_resolution", { width, height });
		glDrawArrays(GL_TRIANGLES, 0, 3);



		ImGuiWindowFlags window_flags = 0;
		window_flags |= ImGuiWindowFlags_NoMove;
		window_flags |= ImGuiWindowFlags_AlwaysAutoResize;

		ImGui::SetNextWindowPos(ImVec2(0, 0), ImGuiCond_Appearing);
		ImGui::SetNextWindowCollapsed(!E3T_wnd_open);
		bool open{ E3T_wnd_open };
		if (!ImGui::Begin("E3T", &open, window_flags))
		{
			E3T_wnd_open = false;
			glfwSetInputMode(pWindow, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
			ImGui::End();
			// Early out if the window is collapsed, as an optimization.
		}
		else
		{
			E3T_wnd_open = true;
			glfwSetInputMode(pWindow, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
			
			shader.render_uniforms();

			static bool styleEditor{ false };
			ImGui::Checkbox("Style Editor", &styleEditor);
			if (styleEditor)
			{
				if (ImGui::Begin("Style Editor")) {
					ImGui::ShowStyleEditor();
				}
				ImGui::End();
			}
			ImGui::Text("Application average:\n%.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
			ImGui::End();
		}


		ImGui::Render();
		ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

		glfwSwapBuffers(pWindow);
		processInput(pWindow);
		glfwPollEvents();
	}
}

	E3T::shutdown();
	return 0;
}

void processInput(GLFWwindow *pWindow)
{
	static bool space_pressed = false;
	if (glfwGetKey(pWindow, GLFW_KEY_SPACE) == GLFW_PRESS)
	{
		space_pressed = true;
	}
	if (glfwGetKey(pWindow, GLFW_KEY_SPACE) == GLFW_RELEASE && space_pressed)
	{
		space_pressed = false;
		E3T_wnd_open = E3T_wnd_open ? false : true;
	}
	if (glfwGetKey(pWindow, GLFW_KEY_ESCAPE) == GLFW_PRESS)
	{
		glfwSetWindowShouldClose(pWindow, true);
	}
	static bool F11_pressed = false;
	if (glfwGetKey(pWindow, GLFW_KEY_F11) == GLFW_PRESS)
	{
		F11_pressed = true;
	}
	if (glfwGetKey(pWindow, GLFW_KEY_F11) == GLFW_RELEASE && F11_pressed)
	{
		F11_pressed = false;
		static int old_width = width, old_height = height;
		static int old_xPos = 0, old_yPos = 0, old_refreshRate = 0;
		if (glfwGetWindowMonitor(pWindow) == nullptr)
		{
			old_width = width;
			old_height = height;
			glfwGetWindowPos(pWindow, &old_xPos, &old_yPos);
			const GLFWvidmode* mode{ glfwGetVideoMode(glfwGetPrimaryMonitor()) };
			glfwSetWindowMonitor(pWindow, glfwGetPrimaryMonitor(), 0, 0, mode->width, mode->height, mode->refreshRate);
		}
		else
		{
			width = old_width;
			height = old_height;
			glfwSetWindowMonitor(pWindow, nullptr, old_xPos, old_yPos, width, height, NULL);
		}
	}
	if (glfwGetKey(pWindow, GLFW_KEY_W) == GLFW_PRESS)
	{
		cam.processKeyboard(CamMovement::FORWARD, dt);
	}
	if (glfwGetKey(pWindow, GLFW_KEY_S) == GLFW_PRESS)
	{
		cam.processKeyboard(CamMovement::BACKWARD, dt);
	}
	if (glfwGetKey(pWindow, GLFW_KEY_A) == GLFW_PRESS)
	{
		cam.processKeyboard(CamMovement::RIGHT, dt);
	}
	if (glfwGetKey(pWindow, GLFW_KEY_D) == GLFW_PRESS)
	{
		cam.processKeyboard(CamMovement::LEFT, dt);
	}
	if (glfwGetKey(pWindow, GLFW_KEY_KP_ADD) == GLFW_PRESS)
	{
		cam.movementSpeed *= 1.1f;
	}
	if (glfwGetKey(pWindow, GLFW_KEY_KP_SUBTRACT) == GLFW_PRESS)
	{
		cam.movementSpeed *= 0.9f;
	}
}
float lastX = width / 2.0f;
float lastY = height / 2.0f;
bool firstMouse = true;
void mouse_callback(GLFWwindow *window, double xpos, double ypos)
{
	if (!E3T_wnd_open)
	{
		if (firstMouse)
		{
			lastX = static_cast<float>(xpos);
			lastY = static_cast<float>(ypos);
			firstMouse = false;
		}

		const float xoffset = static_cast<float>(xpos) - lastX;
		const float yoffset = lastY - static_cast<float>(ypos);

		lastX = (static_cast<float>(xpos));
		lastY = (static_cast<float>(ypos));

		cam.processMouseMovement(xoffset, yoffset);
	}
}
void window_size_callback(GLFWwindow* window, int w, int h) noexcept
{
	width = w; height = h;
	glViewport(0, 0, width, height);
}