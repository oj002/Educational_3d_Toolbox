#pragma once

#include <string>

#include <fstream>
#include <sstream>
#include <functional>
#include <vector>

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


		inline void setBool(const std::string& name, bool v) { GLCall(glUniform1i(getUniformLocation(name), v)); }
		inline void setBVec2(const std::string& name, const glm::bvec2& vec) { GLCall(glUniform2i(getUniformLocation(name), vec.x, vec.y)); }
		inline void setBVec3(const std::string& name, const glm::bvec3& vec) { GLCall(glUniform3i(getUniformLocation(name), vec.x, vec.y, vec.z)); }
		inline void setBVec4(const std::string& name, const glm::bvec4& vec) { GLCall(glUniform4i(getUniformLocation(name), vec.x, vec.y, vec.z, vec.w)); }

		inline void setInt(const std::string& name, int v) { GLCall(glUniform1i(getUniformLocation(name), v)); }
		inline void setIVec2(const std::string& name, const glm::ivec2& vec) { GLCall(glUniform2i(getUniformLocation(name), vec.x, vec.y)); }
		inline void setIVec3(const std::string& name, const glm::ivec3& vec) { GLCall(glUniform3i(getUniformLocation(name), vec.x, vec.y, vec.z)); }
		inline void setIVec4(const std::string& name, const glm::ivec4& vec) { GLCall(glUniform4i(getUniformLocation(name), vec.x, vec.y, vec.z, vec.w)); }

		inline void setUInt(const std::string& name, unsigned int v) { GLCall(glUniform1ui(getUniformLocation(name), v)); }
		inline void setUVec2(const std::string& name, const glm::uvec2& vec) { GLCall(glUniform2ui(getUniformLocation(name), vec.x, vec.y)); }
		inline void setUVec3(const std::string& name, const glm::uvec3& vec) { GLCall(glUniform3ui(getUniformLocation(name), vec.x, vec.y, vec.z)); }
		inline void setUVec4(const std::string& name, const glm::uvec4& vec) { GLCall(glUniform4ui(getUniformLocation(name), vec.x, vec.y, vec.z, vec.w)); }

		inline void setFloat(const std::string& name, float v) { GLCall(glUniform1f(getUniformLocation(name), v)); }
		inline void setVec2(const std::string& name, const glm::vec2& vec) { GLCall(glUniform2f(getUniformLocation(name), vec.x, vec.y)); }
		inline void setVec3(const std::string& name, const glm::vec3& vec) { GLCall(glUniform3f(getUniformLocation(name), vec.x, vec.y, vec.z)); }
		inline void setVec4(const std::string& name, const glm::vec4& vec) { GLCall(glUniform4f(getUniformLocation(name), vec.x, vec.y, vec.z, vec.w)); }

		inline void setDouble(const std::string& name, double v) { GLCall(glUniform1d(getUniformLocation(name), v)); }
		inline void setDVec2(const std::string& name, const glm::dvec2& vec) { GLCall(glUniform2d(getUniformLocation(name), vec.x, vec.y)); }
		inline void setDVec3(const std::string& name, const glm::dvec3& vec) { GLCall(glUniform3d(getUniformLocation(name), vec.x, vec.y, vec.z)); }
		inline void setDVec4(const std::string& name, const glm::dvec4& vec) { GLCall(glUniform4d(getUniformLocation(name), vec.x, vec.y, vec.z, vec.w)); }
		
		inline void setMat2(const std::string& name, const glm::mat2& mat) { GLCall(glUniformMatrix2fv(getUniformLocation(name), 1, GL_FALSE, glm::value_ptr(mat))); }
		inline void setMat3(const std::string& name, const glm::mat3& mat) { GLCall(glUniformMatrix3fv(getUniformLocation(name), 1, GL_FALSE, glm::value_ptr(mat))); }
		inline void setMat4(const std::string& name, const glm::mat4& mat) { GLCall(glUniformMatrix4fv(getUniformLocation(name), 1, GL_FALSE, glm::value_ptr(mat))); }


		void update(const char *filepath);
		void render_uniforms();
	private:
		std::string PaseLib(const std::string &libPath);
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
		std::map<std::string, std::vector<std::function<void()>>> m_imguiCalls;

		#define UNIFORM_VEC(x, name) std::map<std::string, x> u_##name
		UNIFORM_VEC(bool,						bool);
		UNIFORM_VEC(glm::tvec2<bool>,			bvec2);
		UNIFORM_VEC(glm::tvec3<bool>,			bvec3);
		UNIFORM_VEC(glm::tvec4<bool>,			bvec4);

		UNIFORM_VEC(int,						int);
		UNIFORM_VEC(glm::tvec2<int>,			ivec2);
		UNIFORM_VEC(glm::tvec3<int>,			ivec3);
		UNIFORM_VEC(glm::tvec4<int>,			ivec4);

		UNIFORM_VEC(unsigned int,				uint);
		UNIFORM_VEC(glm::tvec2<unsigned int>,	uivec2);
		UNIFORM_VEC(glm::tvec3<unsigned int>,	uivec3);
		UNIFORM_VEC(glm::tvec4<unsigned int>,	uivec4);

		UNIFORM_VEC(float,						float);
		UNIFORM_VEC(glm::tvec2<float>,			vec2);
		UNIFORM_VEC(glm::tvec3<float>,			vec3);
		UNIFORM_VEC(glm::tvec4<float>,			vec4);

		UNIFORM_VEC(double,						double);
		UNIFORM_VEC(glm::tvec2<double>,			dvec2);
		UNIFORM_VEC(glm::tvec3<double>,			dvec3);
		UNIFORM_VEC(glm::tvec4<double>,			dvec4);

		

		#undef UNIFORM_VEC
	};
}
