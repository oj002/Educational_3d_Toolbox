#include "Core.hpp"
#include <glad/glad.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
int width = 800, height = 600;

Cam cam(glm::vec3(0.0f, 0.0f, 3.0f));
float dt = 0.0f;

void processInput(GLFWwindow *pWindow);
void mouse_callback(GLFWwindow * window, double xpos, double ypos);
void window_size_callback(GLFWwindow* window, int w, int h) noexcept;

int main()
{
	E3T::init_glfw();

	GLFWwindow* pWindow{ E3T::createWindow(width, height, "G3T") };
	glfwSetInputMode(pWindow, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
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


	E3T::Shader shader;
	shader.bind();

	E3T::Timer fpsTimer;
	size_t fps{ 0 };
	E3T::Timer timer;
	E3T::Timer dtTimer;
	while (!glfwWindowShouldClose(pWindow))
	{
		dt = dtTimer.restart<float>();

		processInput(pWindow);

		GLCall(glClear(GL_COLOR_BUFFER_BIT));


		shader.setVec3("camUp", cam.up);
		shader.setVec3("camRight", cam.right);
		shader.setVec3("eye", cam.position);
		shader.setFloat("time", timer.getElapsedTime<float>());
		shader.setFloat("dt", dt);
		shader.setVec2("resolution", { width, height });

		glDrawArrays(GL_TRIANGLES, 0, 3);
		glfwSwapBuffers(pWindow);
		glfwPollEvents();
		++fps;
		shader.update("main.glsl");
		if (fpsTimer.getElapsedTime<float>() > 1.0f)
		{
			glfwSetWindowTitle(pWindow, ("E3T     FPS: " + std::to_string(fps)).c_str());
			fpsTimer.restart();
			fps = 0;
		}
	}
	return 0;
}

void processInput(GLFWwindow *pWindow)
{
	if (glfwGetKey(pWindow, GLFW_KEY_ESCAPE) == GLFW_PRESS)
	{
		glfwSetWindowShouldClose(pWindow, true);
	}
	static bool pressed = false;
	if (glfwGetKey(pWindow, GLFW_KEY_F11) == GLFW_PRESS)
	{
		pressed = true;
	}
	if (glfwGetKey(pWindow, GLFW_KEY_F11) == GLFW_RELEASE && pressed)
	{
		pressed = false;
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
}
float lastX = 800.0f / 2.0f;
float lastY = 600.0f / 2.0f;
bool firstMouse = true;
void mouse_callback(GLFWwindow *window, double xpos, double ypos)
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
void window_size_callback(GLFWwindow* window, int w, int h) noexcept
{
	width = w; height = h;
	glViewport(0, 0, width, height);
}