#pragma once

#include <string>

#include <fstream>
#include <sstream>
#include <functional>

#include "Macros.hpp"
#include <glad\glad.h>

#include <glm\glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <imgui\imgui.h>
#include <imgui\imgui_impl_glfw.h>
#include <imgui\imgui_impl_opengl3.h>

#include <map>
#include <unordered_map>

namespace E3T
{
	class Shader
	{
	public:
		Shader();
		~Shader() { GLCall(glDeleteProgram(m_rendererID)); }


		inline void bind() const noexcept { GLCall(glUseProgram(m_rendererID)); }
		inline void unbind() const noexcept { GLCall(glUseProgram(0)); }

		inline void setFloat(const std::string& name, float v) { GLCall(glUniform1f(getUniformLocation(name), v)); }
		inline void setInt(const std::string& name, int v) { GLCall(glUniform1i(getUniformLocation(name), v)); }

		inline void setVec2(const std::string& name, const glm::vec2& vec) { GLCall(glUniform2f(getUniformLocation(name), vec.x, vec.y)); }
		inline void setVec3(const std::string& name, const glm::vec3& vec) { GLCall(glUniform3f(getUniformLocation(name), vec.x, vec.y, vec.z)); }
		inline void setVec4(const std::string& name, const glm::vec4& vec) { GLCall(glUniform4f(getUniformLocation(name), vec.x, vec.y, vec.z, vec.w)); }
		inline void setMat4(const std::string& name, const glm::mat4& mat) { GLCall(glUniformMatrix4fv(getUniformLocation(name), 1, GL_FALSE, glm::value_ptr(mat))); }

		void update(const char *filepath);
	private:
		std::string PaseLib(const char *libPath);
		std::string PaseShader(const char *filePath);
		unsigned int CompileShader(unsigned int type, const std::string& sourc);
		void CreateShader(const std::string& fragmentShader);
		int getUniformLocation(const std::string& name);

		struct Library
		{
			unsigned int id;
			std::string forward_declare;
			long long lastWriteTime;
		};

	private:
		unsigned int m_rendererID;
		unsigned int m_vs;
		std::map<std::string, Library> m_libs;
		std::unordered_map<std::string, int> m_uniformLocationCache;
	};
}