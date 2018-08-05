#define ADD_TO_SHADER \
		shader += "uniform "; \
		shader += type; \
		shader += ' '; \
		shader += name; \
		shader += ";\n"


if (funcName == "SliderFloat")
{
	char dummy; float a{ 0.0f }, b{ 0.0f };
	ss >> a;
	do { ss >> dummy; } while (dummy != ',');
	ss >> b;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (dummy) ss >> this->u_float[name];
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name, a, b]() {
		ImGui::SliderFloat(name.c_str(), &this->u_float[name], a, b);
	});
	ADD_TO_SHADER;
}
else if (funcName == "SliderAngle")
{
	char dummy; float a{ 0.0f }, b{ 0.0f };
	ss >> a;
	do { ss >> dummy; } while (dummy != ',');
	ss >> b;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) ss >> this->u_float[name];
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name, a, b]() {
		ImGui::SliderAngle(name.c_str(), &this->u_float[name], a, b);
	});
	ADD_TO_SHADER;
}
else if (funcName == "SliderFloat2")
{
	char dummy; float a{ 0.0f }, b{ 0.0f };
	ss >> a;
	do { ss >> dummy; } while (dummy != ',');
	ss >> b;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) {
		do { ss >> dummy; } while (dummy != '(');
		ss >> this->u_vec2[name].x;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec2[name].y;
	};
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name, a, b]() {
		ImGui::SliderFloat2(name.c_str(), glm::value_ptr(this->u_vec2[name]), a, b);
	});
	ADD_TO_SHADER;
}
else if (funcName == "SliderFloat3")
{
	char dummy; float a{ 0.0f }, b{ 0.0f };
	ss >> a;
	do { ss >> dummy; } while (dummy != ',');
	ss >> b;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) {
		do { ss >> dummy; } while (dummy != '(');
		ss >> this->u_vec3[name].x;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec3[name].y;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec3[name].z;
	};
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name, a, b]() {
		ImGui::SliderFloat3(name.c_str(), glm::value_ptr(this->u_vec3[name]), a, b);
	});
	ADD_TO_SHADER;
}
else if (funcName == "ColorPicker3")
{
	char dummy;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) {
		do { ss >> dummy; } while (dummy != '(');
		ss >> this->u_vec3[name].x;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec3[name].y;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec3[name].z;
	};
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name]() {
		ImGui::ColorPicker3(name.c_str(), glm::value_ptr(this->u_vec3[name]));
	});
	ADD_TO_SHADER;
}
else if (funcName == "SliderFloat4")
{
	char dummy; float a{ 0.0f }, b{ 0.0f };
	ss >> a;
	do { ss >> dummy; } while (dummy != ',');
	ss >> b;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) {
		do { ss >> dummy; } while (dummy != '(');
		ss >> this->u_vec4[name].x;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec4[name].y;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec4[name].z;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec4[name].w;
	};
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name, a, b]() {
		ImGui::SliderFloat4(name.c_str(), glm::value_ptr(this->u_vec4[name]), a, b);
	});
	ADD_TO_SHADER;
}
else if (funcName == "ColorPicker4")
{
	char dummy;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) {
		do { ss >> dummy; } while (dummy != '(');
		ss >> this->u_vec4[name].x;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec4[name].y;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec4[name].z;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_vec4[name].w;
	};
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name]() {
		ImGui::ColorPicker4(name.c_str(), glm::value_ptr(this->u_vec4[name]));
	});
	ADD_TO_SHADER;
}
else if (funcName == "SliderInt")
{
	char dummy; int a{ 0 }, b{ 0 };
	ss >> a;
	do { ss >> dummy; } while (dummy != ',');
	ss >> b;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) ss >> this->u_int[name];
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name, a, b]() {
		ImGui::SliderInt(name.c_str(), &this->u_int[name], a, b);
	});
	ADD_TO_SHADER;
}
else if (funcName == "SliderInt2")
{
	char dummy; int a{ 0 }, b{ 0 };
	ss >> a;
	do { ss >> dummy; } while (dummy != ',');
	ss >> b;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) {
		do { ss >> dummy; } while (dummy != '(');
		ss >> this->u_ivec2[name].x;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_ivec2[name].y;
	};
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name, a, b]() {
		ImGui::SliderInt2(name.c_str(), glm::value_ptr(this->u_ivec2[name]), a, b);
	});
	ADD_TO_SHADER;
}
else if (funcName == "SliderInt3")
{
	char dummy; int a{ 0 }, b{ 0 };
	ss >> a;
	do { ss >> dummy; } while (dummy != ',');
	ss >> b;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) {
		do { ss >> dummy; } while (dummy != '(');
		ss >> this->u_ivec3[name].x;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_ivec3[name].y;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_ivec3[name].z;
	};
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name, a, b]() {
		ImGui::SliderInt3(name.c_str(), glm::value_ptr(this->u_ivec3[name]), a, b);
	});
	ADD_TO_SHADER;
}
else if (funcName == "SliderInt4")
{
	char dummy; int a{ 0 }, b{ 0 };
	ss >> a;
	do { ss >> dummy; } while (dummy != ',');
	ss >> b;
	do { ss >> dummy; } while (dummy != '=' && !ss.eof());
	if (!ss.eof()) {
		do { ss >> dummy; } while (dummy != '(');
		ss >> this->u_ivec4[name].x;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_ivec4[name].y;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_ivec4[name].z;
		do { ss >> dummy; } while (dummy != ',');
		ss >> this->u_ivec4[name].w;
	};
	do { ss >> dummy; } while (dummy != '@' && !ss.eof());
	std::string node("uniforms");
	if (!ss.eof()) ss >> node;
	m_imguiCalls[node].push_back([this, name, a, b]() {
		ImGui::SliderInt4(name.c_str(), glm::value_ptr(this->u_ivec4[name]), a, b);
	});
	ADD_TO_SHADER;
}
#undef ADD_TO_SHADER