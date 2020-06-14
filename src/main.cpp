#include "util.h"
#include "version.h"

#include <Qaterial/Qaterial.hpp>

#include <QGuiApplication>
#include <QStyleHints>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // useHoverEffects is disabled for wasm
    const auto styleHints = QGuiApplication::styleHints();
    styleHints->setUseHoverEffects(true);

    engine.addImportPath("qrc:///");
    qaterial::loadQmlResources();
    qaterial::registerQmlTypes();

    qmlRegisterSingletonType<Util>("Util", 1, 0, "Util", Util::qmlSingletonRegister);
    engine.load(QUrl("qrc:/main.qml"));

    return app.exec();
}
